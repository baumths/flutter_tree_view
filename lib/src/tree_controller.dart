import 'package:flutter/foundation.dart';

/// The default level used for root nodes when flattening the tree.
const int treeRootLevel = 0;

/// Signature of a function that takes a `T` node and returns an `Iterable<T>`.
///
/// Used to get the children of a node in a tree.
typedef ChildrenProvider<T> = Iterable<T> Function(T node);

/// Signature of a function that takes a `T` node and returns a `T?` parent.
///
/// Used to get the parent of a node in a tree.
typedef ParentProvider<T> = T? Function(T node);

/// Signature of a function used to visit nodes during tree traversal.
typedef Visitor<T> = void Function(T node);

/// Signature of a function that takes a `T` node and returns a `bool`.
///
/// Used when traversing a tree to decide if the children of [node] should be
/// traversed or skipped.
typedef DescendCondition<T> = bool Function(T node);

/// Signature of a function that takes a `T` node and returns a `bool`.
///
/// Used when traversing the tree in breadth first order to decide whether the
/// traversal should stop.
typedef ReturnCondition<T> = bool Function(T node);

/// A controller used to dynamically manage the state of a tree.
///
/// Whenever this controller notifies its listeners any attached tree views
/// will assume that the tree structure changed in some way and will rebuild
/// their internal flat representaton of the tree, showing/hiding the updated
/// nodes (if any).
///
/// Usage:
/// ```dart
/// class Node {
///   Node(this.children);
///   List<Node> children;
/// }
///
/// final TreeController<Node> treeController = TreeController<Node>(
///   roots: <Node>[
///     Node(<Node>[]),
///   ],
///   childrenProvider: (Node node) => node.children,
/// );
/// ```
///
/// The default implementations of [getExpansionState] and [setExpansionState]
/// use a [Set] to manage the expansion state of tree nodes as follows:
/// - getExpansionState(node) = [Set.contains]
/// - setExpansionState(node, true) = [Set.add]
/// - setExpansionState(node, false) = [Set.remove]
///
/// Those methods can be overridden to use other data structures if desired.
/// Example:
/// ```dart
/// class Node {
///   bool isExpanded = false;
/// }
///
/// class MyTreeController extends TreeController<Node> {
///   @override
///   bool getExpansionState(Node node) => node.isExpanded;
///
///   // Do not call `notifyListeners` from this method as it is called many
///   // times recursively in cascading operations.
///   @override
///   void setExpansionState(Node node, bool expanded) {
///     node.isExpanded = expanded;
///   }
/// }
/// ```
class TreeController<T extends Object> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// The [roots] parameter should contain all nodes that occupy the level `0`
  /// of the tree, these nodes are going to be used as a starting point when
  /// traversing the tree and building tree views.
  TreeController({
    required Iterable<T> roots,
    required this.childrenProvider,
    this.parentProvider,
  }) : _roots = roots;

  /// The roots of the tree.
  ///
  /// These nodes are used as a starting point when traversing the tree.
  Iterable<T> get roots => _roots;
  Iterable<T> _roots;
  set roots(Iterable<T> nodes) {
    if (nodes == _roots) return;
    _roots = nodes;
    rebuild();
  }

  /// A callback used when building the flat representation of the tree to get
  /// the direct children of the tree node passed to it.
  ///
  /// Avoid doing heavy computations in this callback since it is going to be
  /// called a lot when traversing the tree.
  ///
  /// Example using nested objects:
  /// ```dart
  /// class Node {
  ///   List<Node> children;
  /// }
  ///
  /// Iterable<Node> childrenProvider(Node node) => node.children;
  /// ```
  ///
  /// Example using a Map cache:
  /// ```dart
  /// class Data {
  ///   final int id;
  /// }
  ///
  /// final Map<int, List<Data>> childrenCache = <int, List<Data>>{};
  ///
  /// Iterable<Data> childrenProvider(Data parent) {
  ///   return childrenCache[parent.id] ?? const Iterable.empty();
  /// },
  /// ```
  ///
  /// Do not attempt to load the children of a node in this callback as it
  /// would significantly slow down tree traversal which might couse the ui to
  /// hang. Prefer doing such operations on a user interaction (e.g., a button
  /// press, keyboard shortcut, etc.). When lazy loading, temporarily return
  /// an empty iterable so tree traversal can continue. Once the loading is
  /// done, set the expansion state of the parent node to `true` and call
  /// [rebuild] to reveal the loaded nodes.
  final ChildrenProvider<T> childrenProvider;

  /// A getter callback that should return the direct parent of the tree node
  /// that is given to it.
  ///
  /// This callback must return `null` when either a root node or an orphan node
  /// is given to it. Otherwise this could lead to infinite loops while walking
  /// up the ancestors of a tree node.
  ///
  /// Avoid doing heavy computations in this callback as it may be called a lot
  /// while walking the ancestors of a tree node.
  ///
  /// Example:
  /// ```dart
  /// class Node {
  ///   Node? parent;
  /// }
  ///
  /// TreeController<Node> treeController = TreeController<Node>(
  ///   ...
  ///   parentProvider: (Node node) => node.parent,
  /// );
  /// ```
  ///
  /// Omitting this callback could lead to poor performance as the methods
  /// that walk up the tree to visit ancestor nodes would potentially have to
  /// traverse the entire tree to locate a given node to collect its path.
  /// Whereas with this callback, the path finding would only iterate once for
  /// each ancestor of the given node, stopping when the first `null` ancestor
  /// is reached.
  final ParentProvider<T>? parentProvider;

  Set<T> get _expandedNodes => _expandedNodesCache ??= <T>{};
  Set<T>? _expandedNodesCache;

  /// The current expansion state of [node].
  ///
  /// If this method returns `true`, the children of [node] should be visible
  /// in tree views.
  bool getExpansionState(T node) {
    return _expandedNodesCache?.contains(node) ?? false;
  }

  /// Updates the expansion state of [node] to the value of [expanded].
  ///
  /// When overriding this method, do not call `notifyListeners` as this may be
  /// called many times recursively in cascading operations.
  void setExpansionState(T node, bool expanded) {
    expanded ? _expandedNodes.add(node) : _expandedNodes.remove(node);
  }

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, node added/removed/reordered, etc...), so that listeners
  /// may handle the updated values. Most methods of this controller (like
  /// expand, collapse, etc.) already call [rebuild] implicitly.
  ///
  /// Example:
  /// ```dart
  /// class Node {
  ///   List<Node> children;
  /// }
  ///
  /// TreeController<Node> controller = ...;
  ///
  /// void addChildren(Node parent, Iterable<Node> children) {
  ///   parent.children.addAll(children);
  ///   controller.rebuild();
  /// }
  ///```
  void rebuild() => notifyListeners();

  void _collapse(T node) => setExpansionState(node, false);
  void _expand(T node) => setExpansionState(node, true);

  /// Updates the expansion state of [node] to the opposite state, then calls
  /// [rebuild].
  void toggleExpansion(T node) {
    setExpansionState(node, !getExpansionState(node));
    rebuild();
  }

  /// Sets the expansion state of [node] to `true`, then calls [rebuild].
  ///
  /// If [node] is already expanded, nothing happens.
  void expand(T node) {
    if (getExpansionState(node)) return;
    _expand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `false`, then calls [rebuild].
  ///
  /// If [node] is already collapsed, nothing happens.
  void collapse(T node) {
    if (!getExpansionState(node)) return;
    _collapse(node);
    rebuild();
  }

  void _applyCascadingAction(Iterable<T> nodes, Visitor<T> action) {
    for (final T node in nodes) {
      action(node);
      _applyCascadingAction(childrenProvider(node), action);
    }
  }

  /// Traverses the subtrees of [nodes] in depth first order expanding every
  /// visited node, then calls [rebuild].
  void expandCascading(Iterable<T> nodes) {
    if (nodes.isEmpty) return;
    _applyCascadingAction(nodes, _expand);
    rebuild();
  }

  /// Traverses the subtrees of [nodes] in depth first order collapsing every
  /// visited node, then calls [rebuild].
  void collapseCascading(Iterable<T> nodes) {
    if (nodes.isEmpty) return;
    _applyCascadingAction(nodes, _collapse);
    rebuild();
  }

  /// Expands all nodes of this tree recursively.
  ///
  /// This method delegates its call to [expandCascading] passing in [roots]
  /// as the nodes to be expanded.
  void expandAll() => expandCascading(roots);

  /// Collapses all nodes of this tree recursively.
  ///
  /// This method delegates its call to [collapseCascading] passing in [roots]
  /// as the nodes to be collapsed.
  void collapseAll() => collapseCascading(roots);

  /// Walks up the ancestors of [node] setting their expansion state to `true`.
  /// Note: [node] is not expanded by this method.
  ///
  /// This can be used to reveal a hidden node (e.g. when searching for a node
  /// in a search view).
  ///
  /// [parentProvider] should return the direct parent of the given node or
  /// `null` if the root node is reached, this callback is used to traverse the
  /// ancestors of [node].
  void expandAncestors(
    T node, [
    @Deprecated('Use `TreeController.parentProvider` instead.')
    ParentProvider<T>? parentProvider,
  ]) {
    parentProvider ??= this.parentProvider;

    if (parentProvider == null) {
      assert(
        false,
        '`TreeController.expandAncestors()` requires a `parentProvider` to work. '
        'Either define a `TreeController.parentProvider` (preferred way) or '
        'provide it directly to the `expandAncestors` method (deprecated way).',
      );
      return;
    }

    T? current = parentProvider(node);

    if (current == null) return;

    while (current != null) {
      _expand(current);
      current = parentProvider(current);
    }

    rebuild();
  }

  /// Whether all root nodes of this tree are expanded.
  bool get areAllRootsExpanded => roots.every(getExpansionState);

  /// Whether all root nodes of this tree are collapsed.
  bool get areAllRootsCollapsed => !roots.any(getExpansionState);

  /// Whether **all** nodes of this tree are expanded.
  ///
  /// Traverses the tree in breadth first order checking the expansion state of
  /// each visited node. The traversal will return early if it finds a collapsed
  /// node.
  bool get isTreeExpanded {
    bool allNodesExpanded = false;

    breadthFirstSearch(
      returnCondition: (T node) {
        final bool isExpanded = getExpansionState(node);
        allNodesExpanded = isExpanded;
        // Stop the traversal if [node] is not expanded
        return !isExpanded;
      },
    );

    return allNodesExpanded;
  }

  /// Whether **all** nodes of this tree are collapsed.
  ///
  /// Traverses the tree in breadth first order checking the expansion state of
  /// each visited node. The traversal will return early if it finds an expanded
  /// node.
  bool get isTreeCollapsed {
    bool allNodesCollapsed = true;

    breadthFirstSearch(
      returnCondition: (T node) {
        final bool isExpanded = getExpansionState(node);
        allNodesCollapsed = !isExpanded;
        // Stop the traversal if [node] is expanded
        return isExpanded;
      },
    );

    return allNodesCollapsed;
  }

  /// Checks if [potentialAncestor] is present in the path from [node] to its
  /// root node.
  ///
  /// By default, [node] is not checked against [potentialAncestor]. Set
  /// [checkForEquality] to `true` so an additional `node == potentialAncestor`
  /// check is done.
  ///
  /// Consider defining a [TreeController.parentProvider] to avoid having
  /// to traverse the, in the worst case, entire tree to find [node]'s path.
  /// When [TreeController.parentProvider] is defined, this iterates once for
  /// each ancestor node in [node]'s path returning early if [potentialAncestor]
  /// is found.
  bool checkNodeHasAncestor({
    required T node,
    required T potentialAncestor,
    bool checkForEquality = false,
  }) {
    if (checkForEquality && node == potentialAncestor) {
      return true;
    }

    if (parentProvider case final ParentProvider<T> parentProvider?) {
      T? current = parentProvider(node);
      bool foundAncestor = false;

      while (!(foundAncestor || current == null)) {
        foundAncestor = current == potentialAncestor;
        current = parentProvider(current);
      }

      return foundAncestor;
    } else {
      bool foundAncestor = false;

      bool traverse(Iterable<T> nodes) {
        for (final T current in nodes) {
          if (current == node) {
            // Target found, returning `true` as we are in the right path
            return true;
          }

          // Move into [current]'s subtree
          if (traverse(childrenProvider(current))) {
            foundAncestor = current == potentialAncestor;

            // Continue returning `true` so all ancestors are visited
            return true;
          }
        }

        return false;
      }

      traverse(roots);
      return foundAncestor;
    }
  }

  /// Traverses the subtrees of [startingNodes] in breadth first order. If
  /// [startingNodes] is not provided, [roots] will be used instead.
  ///
  /// [descendCondition] is used to determine if the descendants of the node
  /// passed to it should be traversed. When not provided, defaults to
  /// [alwaysReturnsTrue], a function that always returns `true` which leads
  /// to every node on the tree being visited by this traversal.
  ///
  /// [returnCondition] is used as a predicate to decide if the iteration should
  /// be stopped. If this callback returns `true` the node that was passed to
  /// it is returned from this method. When not provided, defaults to
  /// [alwaysReturnsFalse], a function that always returns `false` which leads
  /// to every node on the tree being visited by this traversal.
  ///
  /// An optional [onTraverse] callback can be provided to apply an action to
  /// each visited node. This callback is called prior to [returnCondition] and
  /// [descendCondition] making it possible to update a node before checking
  /// its properties.
  T? breadthFirstSearch({
    Iterable<T>? startingNodes,
    DescendCondition<T> descendCondition = alwaysReturnsTrue,
    ReturnCondition<T> returnCondition = alwaysReturnsFalse,
    Visitor<T>? onTraverse,
  }) {
    final List<T> nodes = List<T>.of(startingNodes ?? roots);

    while (nodes.isNotEmpty) {
      final T node = nodes.removeAt(0);

      onTraverse?.call(node);

      if (returnCondition(node)) {
        return node;
      }

      if (descendCondition(node)) {
        nodes.addAll(childrenProvider(node));
      }
    }

    return null;
  }

  /// Traverses the subtrees of [roots] creating [TreeEntry] instances for
  /// each visited node.
  ///
  /// Every new [TreeEntry] instance is provided to [onTraverse] right after it
  /// is created, before descending into its subtrees.
  ///
  /// [descendCondition] is used to determine if the descendants of the entry
  /// passed to it should be traversed. When not provided, defaults to
  /// `(TreeEntry<T> entry) => entry.isExpanded`.
  ///
  /// If [rootEntry] is provided, its children will be used instead of [roots]
  /// as the roots during traversal. This entry can be used to build a subtree
  /// keeping the context of the ancestors in the main tree. This parameter
  /// is used by [SliverAnimatedTree] when animating the expand and collapse
  /// operations to animate subtrees in and out of the view without losing
  /// indentation context of the main tree.
  void depthFirstTraversal({
    required Visitor<TreeEntry<T>> onTraverse,
    DescendCondition<TreeEntry<T>>? descendCondition,
    TreeEntry<T>? rootEntry,
  }) {
    final DescendCondition<TreeEntry<T>> shouldDescend =
        descendCondition ?? defaultDescendCondition;

    int treeIndex = 0;

    void createTreeEntriesRecursively({
      required TreeEntry<T>? parent,
      required Iterable<T> nodes,
      required int level,
    }) {
      TreeEntry<T>? entry;

      for (final T node in nodes) {
        final Iterable<T> children = childrenProvider(node);
        entry = TreeEntry<T>(
          parent: parent,
          node: node,
          index: treeIndex++,
          isExpanded: getExpansionState(node),
          level: level,
          hasChildren: children.isNotEmpty,
        );

        onTraverse(entry);

        if (shouldDescend(entry) && entry.hasChildren) {
          createTreeEntriesRecursively(
            parent: entry,
            nodes: children,
            level: level + 1,
          );
        }
      }

      entry?._hasNextSibling = false;
    }

    if (rootEntry != null) {
      createTreeEntriesRecursively(
        parent: rootEntry,
        nodes: childrenProvider(rootEntry.node),
        level: rootEntry.level + 1,
      );
    } else {
      createTreeEntriesRecursively(
        parent: null,
        nodes: roots,
        level: treeRootLevel,
      );
    }
  }

  /// The default [DescendCondition] used by [depthFirstTraversal].
  @visibleForTesting
  bool defaultDescendCondition(TreeEntry<T> entry) => entry.isExpanded;

  @override
  void dispose() {
    _roots = const Iterable.empty();
    _expandedNodesCache = null;
    super.dispose();
  }
}

/// A function that can take a nullable [Object] and will always return `true`.
///
/// Used in other function declarations as a constant default parameter.
bool alwaysReturnsTrue([Object? _]) => true;

/// A function that can take a nullable [Object] and will always return `false`.
///
/// Used in other function declarations as a constant default parameter.
bool alwaysReturnsFalse([Object? _]) => false;

/// Used to store useful information about [node] in a tree.
///
/// Instances of this class are short lived, created by [TreeController]
/// when traversing the tree; each traversal creates a new [TreeEntry]
/// for each visited node with up to date values.
///
/// To make sure that tree views are always up to date make sure to call
/// [TreeController.rebuild] to notify its listeners that the tree structure
/// changed in some way and they should update their cached values.
class TreeEntry<T extends Object> with Diagnosticable {
  /// Creates a [TreeEntry].
  TreeEntry({
    required this.parent,
    required this.node,
    required this.index,
    required this.level,
    required this.isExpanded,
    required this.hasChildren,
    bool hasNextSibling = true,
  }) : _hasNextSibling = hasNextSibling;

  /// The direct parent of [node] on the tree, which was collected during
  /// traversal.
  final TreeEntry<T>? parent;

  /// The tree node that originated this entry.
  final T node;

  /// The index of [node] in the flat tree list that originated this entry.
  final int index;

  /// The level of the node that owns this entry on the tree. Example:
  ///
  /// 0  1  2  3
  /// A  ⋅  ⋅  ⋅
  /// └─ B  ⋅  ⋅
  /// ⋅  ├─ C  ⋅
  /// ⋅  │  └─ D
  /// ⋅  └─ E
  /// F  ⋅
  /// └─ G
  final int level;

  /// The expansion state of [node].
  ///
  /// This value may have changed since this entry was created.
  final bool isExpanded;

  /// Whether [node] has any child nodes.
  ///
  /// This value is gotten from calling [TreeController.childrenProvider] with
  /// [node] an checking if the returned iterable is not empty.
  ///
  /// This value may have changed since this entry was created.
  final bool hasChildren;

  /// Whether the node that owns this entry has another node after it at the
  /// same level.
  ///
  /// Used when painting lines to decide if a node should have a vertical line
  /// that connects it to its next sibling. If a node is the last child of its
  /// parent, a half vertical line "└─" is painted instead of a full one "├─".
  ///
  /// Example:
  ///
  /// Root
  ///  ├─ Node <- `hasNextSibling = true`
  ///  ├─ Node <- `hasNextSibling = true`
  ///  └─ Node <- `hasNextSibling = false`
  bool get hasNextSibling => _hasNextSibling;
  bool _hasNextSibling;

  /// Whether this entry should skip being indented.
  ///
  /// Nodes with a level smaller or equal to [treeRootLevel] are not indented.
  bool get skipIndentAndPaint => level <= treeRootLevel;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T?>('parent node', parent?.node))
      ..add(DiagnosticsProperty<T>('node', node))
      ..add(DiagnosticsProperty<int>('index', index))
      ..add(DiagnosticsProperty<bool>('expanded', isExpanded))
      ..add(DiagnosticsProperty<int>('level', level))
      ..add(DiagnosticsProperty<bool>('has children', hasChildren))
      ..add(DiagnosticsProperty<bool>('has next sibling', hasNextSibling));
  }
}
