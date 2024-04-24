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

/// Signature of a function that takes a `T` value and returns a `bool`.
typedef ValuePredicate<T> = bool Function(T value);

/// Signature of a function that takes a `T` node and returns a `bool`.
///
/// Used when traversing a tree to decide if the children of [node] should be
/// traversed or skipped.
@Deprecated('Use ValuePredicate instead.')
typedef DescendCondition<T> = ValuePredicate<T>;

/// Signature of a function that takes a `T` node and returns a `bool`.
///
/// Used when traversing the tree in breadth first order to decide whether the
/// traversal should stop.
@Deprecated('Use ValuePredicate instead.')
typedef ReturnCondition<T> = ValuePredicate<T>;

/// A controller used to dynamically manage the state of a tree.
///
/// Whenever this controller notifies its listeners any attached tree views
/// will assume that the tree structure changed in some way and will rebuild
/// their internal flat representaton of the tree, showing/hiding the updated
/// nodes (if any).
///
/// Make sure to define a [parentProvider] when using methods that depend on
/// it, like [expandAncestors] and [checkNodeHasAncestor], or indirectly depend
/// on it like the drag and drop widgets [TreeDraggable] and [TreeDragTarget].
///
/// Usage:
/// ```dart
/// class Node {
///   Node(this.children);
///   List<Node> children;
///   Node? parent;
/// }
///
/// final TreeController<Node> treeController = TreeController<Node>(
///   roots: <Node>[
///     Node(<Node>[]),
///   ],
///   childrenProvider: (Node node) => node.children,
///   parentProvider: (Node node) => node.parent,
/// );
/// ```
///
/// The default implementations of [getExpansionState] and [setExpansionState]
/// uses the `toggledNodes` [Set] to manage the expansion state of tree nodes.
///
/// Those methods can be overridden to use other data structures as desired.
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
  ///
  /// The [parentProvider] callback should return the direct parent of the tree
  /// node that's given to it or null when given a root node. Some methods like
  /// [checkNodeHasAncestor] require this callback to be defined and will throw
  /// an [AssertionError] in debug mode. When [parentProvider] is not defined,
  /// [TreeController.parentProvider] is set to a callback that always returns
  /// null.
  TreeController({
    required Iterable<T> roots,
    required this.childrenProvider,
    ParentProvider<T>? parentProvider,
    this.defaultExpansionState = false,
  }) : _roots = roots {
    assert(() {
      _debugHasParentProvider = parentProvider != null;
      return true;
    }());
    this.parentProvider = parentProvider ?? (T node) => null;
  }

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
  /// would significantly slow down tree traversal which might cause the ui to
  /// hang. Prefer doing such operations on a user interaction (e.g., a button
  /// press, keyboard shortcut, etc.). When lazy loading, temporarily return
  /// an empty iterable so tree traversal can continue. Once the loading is
  /// done, set the expansion state of the parent node to `true` and call
  /// [rebuild] to reveal the loaded nodes.
  final ChildrenProvider<T> childrenProvider;

  /// A getter callback that should return the direct parent of the tree node
  /// that is given to it or null if given a root node.
  ///
  /// This callback must return `null` when either a root node or an orphan node
  /// is given to it. Otherwise this could lead to infinite loops while walking
  /// up the ancestors of a tree node.
  ///
  /// When not defined, this will be set to a callback that always returns null.
  ///
  /// Some methods like [expandAncestors] and [checkNodeHasAncestor] depend on
  /// this callback and will throw an [AssertionError] in debug mode when not
  /// defined.
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
  late final ParentProvider<T> parentProvider;

  /// Determines the initial expansion state of tree nodes.
  ///
  /// This value is used to define whether a node should be expanded or
  /// collapsed by default.
  ///
  /// When set to true, all nodes are expanded by default, revealing their
  /// subtrees in tree views. When set to false, all nodes are collapsed by
  /// default, hiding their subtrees in tree views.
  ///
  /// Defaults to `false`.
  final bool defaultExpansionState;

  /// Holds all the expanded OR collapsed nodes, depending on the value of
  /// [defaultExpansionState].
  ///
  /// This should not be manipulated directly, instead use [getExpansionState]
  /// and [setExpansionState]. This was made public for state restoration and
  /// persistence purposes only.
  ///
  /// This will hold every and only:
  /// - expanded nodes when [defaultExpansionState] is set to false.
  /// - collapsed nodes when [defaultExpansionState] is set to true.
  ///
  /// Deciding whether to hold expanded or collapsed nodes is done through an
  /// XOR operation (^) on `Set.contains()`. The same applies to `Set.add()`
  /// and `Set.remove()` which are swapped depending on [defaultExpansionState].
  late final Set<T> toggledNodes = <T>{};

  /// The current expansion state of [node].
  ///
  /// If this method returns `true`, the children of [node] should be visible
  /// in tree views.
  bool getExpansionState(T node) {
    return toggledNodes.contains(node) ^ defaultExpansionState;
  }

  /// Updates the expansion state of [node] to the value of [expanded].
  ///
  /// When overriding this method, do not call `notifyListeners` as this may be
  /// called many times recursively in cascading operations.
  void setExpansionState(T node, bool expanded) {
    expanded ^ defaultExpansionState
        ? toggledNodes.add(node)
        : toggledNodes.remove(node);
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
  ///
  /// This method depends on [TreeController.parentProvider] and will throw an
  /// [AssertionError] in debug mode if [parentProvider] is not defined.
  void expandAncestors(
    T node, [
    @Deprecated('Use [TreeController.parentProvider] instead.')
    ParentProvider<T>? parentProvider,
  ]) {
    assert(() {
      if (parentProvider == null) return _debugCheckHasParentProvider();
      return true;
    }());
    parentProvider ??= this.parentProvider;

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
  /// This method requires a [parentProvider] to be defined and will throw an
  /// [AssertionError] in debug mode.
  bool checkNodeHasAncestor({
    required T node,
    required T potentialAncestor,
    bool checkForEquality = false,
  }) {
    assert(_debugCheckHasParentProvider());

    if (checkForEquality && node == potentialAncestor) {
      return true;
    }

    T? current = parentProvider(node);
    bool foundAncestor = false;

    while (!(foundAncestor || current == null)) {
      foundAncestor = current == potentialAncestor;
      current = parentProvider(current);
    }

    return foundAncestor;
  }

  /// Traverses the tree looking for nodes that match the given [predicate].
  ///
  /// The returned [TreeSearchResult] contains all direct and indirect matches,
  /// i.e., a direct match means the predicate returned true for that given
  /// node, and an indirect match means the given node is not a match, but it
  /// has one or more matching nodes in its subtree.
  ///
  /// The absence of a node in [TreeSearchResult.matches.keys] means that itself
  /// as well as its entire subtree didn't match the search predicate, or the
  /// given node was not reached during tree traversal.
  TreeSearchResult<T> search(ValuePredicate<T> predicate) {
    final Map<T, TreeSearchMatch> allMatches = <T, TreeSearchMatch>{};

    (int subtreeNodeCount, int subtreeMatchCount) traverse(Iterable<T> nodes) {
      int totalNodeCount = 0;
      int totalMatchCount = 0;

      for (final T child in nodes) {
        if (predicate(child)) {
          totalMatchCount++;
          allMatches[child] = const TreeSearchMatch();
        }

        final (int nodes, int matches) = traverse(childrenProvider(child));
        totalNodeCount += nodes + 1;
        totalMatchCount += matches;

        if (matches > 0) {
          allMatches[child] = TreeSearchMatch(
            isDirectMatch: allMatches[child]?.isDirectMatch ?? false,
            subtreeNodeCount: nodes,
            subtreeMatchCount: matches,
          );
        }
      }
      return (totalNodeCount, totalMatchCount);
    }

    final (int totalNodeCount, int totalMatchCount) = traverse(roots);
    return TreeSearchResult<T>(
      matches: allMatches,
      totalNodeCount: totalNodeCount,
      totalMatchCount: totalMatchCount,
    );
  }

  /// Traverses the subtrees of [startingNodes] in breadth first order. If
  /// [startingNodes] is not provided, [roots] will be used instead.
  ///
  /// [descendCondition] is used to determine if the descendants of the node
  /// passed to it should be traversed. When not provided, defaults to a
  /// function that always returns `true` which leads to every node on the
  /// tree being visited by this traversal.
  ///
  /// [returnCondition] is used as a predicate to decide if the iteration
  /// should be stopped. If this callback returns `true` the node that was
  /// passed to it is returned from this method. When not provided, defaults
  /// to a function that always returns `false` which leads to every node on
  /// the tree being visited by this traversal.
  ///
  /// An optional [onTraverse] callback can be provided to apply an action to
  /// each visited node. This callback is called prior to [returnCondition] and
  /// [descendCondition] making it possible to update a node before checking
  /// its properties.
  T? breadthFirstSearch({
    Iterable<T>? startingNodes,
    ValuePredicate<T>? descendCondition,
    ValuePredicate<T>? returnCondition,
    Visitor<T>? onTraverse,
  }) {
    descendCondition ??= (T _) => true;
    returnCondition ??= (T _) => false;
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
    ValuePredicate<TreeEntry<T>>? descendCondition,
    TreeEntry<T>? rootEntry,
  }) {
    final ValuePredicate<TreeEntry<T>> shouldDescend =
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

  /// The default `descendCondition` used by [depthFirstTraversal].
  @visibleForTesting
  bool defaultDescendCondition(TreeEntry<T> entry) => entry.isExpanded;

  bool _debugHasParentProvider = false;

  bool _debugCheckHasParentProvider() {
    assert(() {
      if (_debugHasParentProvider) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('[TreeController.parentProvider] is not defined.'),
        ErrorDescription(
          'Some [TreeController] methods like `checkNodeHasAncestor()` '
          'used by [TreeDragTarget] require a `parentProvider` to work.',
        ),
      ]);
    }());
    return true;
  }

  @override
  void dispose() {
    _roots = const Iterable.empty();
    toggledNodes.clear();
    super.dispose();
  }
}

/// @nodoc
@Deprecated('Use an annonymous callback instead, e.g., `(Object? _) => true.`')
bool alwaysReturnsTrue([Object? _]) => true;

/// @nodoc
@Deprecated('Use an annonymous callback instead, e.g., `(Object? _) => false`.')
bool alwaysReturnsFalse([Object? _]) => false;

/// Represents the result of a search operation on a tree.
///
/// See also:
/// * [TreeSearchMatch], which holds the search match details of a single node
///   and its subtree.
/// * [TreeController.search], which traverses a tree looking for nodes that
///   match the given predicate.
class TreeSearchResult<T extends Object> with Diagnosticable {
  /// Creates a [TreeSearchResult].
  const TreeSearchResult({
    required this.matches,
    this.totalNodeCount = 0,
    this.totalMatchCount = 0,
  });

  /// A [Map] of `node -> TreeSearchMatch` that represents a direct or indirect
  /// match of a search operation on a tree.
  ///
  /// The absence of a node means neither itself nor any of its descendants
  /// matched the search predicate.
  ///
  /// If a node is present in this map, it was either a direct search match
  /// (i.e., the search predicate returned true for itself) or indirect (i.e.,
  /// the search predicate returned true for one or more descendant nodes).
  ///
  /// The values in this map are not arranged in any particular order.
  ///
  /// See also:
  /// * [matchOf] which returns the [TreeSearchMatch] (if any) of a given node.
  final Map<T, TreeSearchMatch> matches;

  /// The total number of nodes visited by the traversal.
  final int totalNodeCount;

  /// The total number of nodes that match the search predicate.
  final int totalMatchCount;

  /// The search result match values of [node].
  ///
  /// If this returns null, either [node] wasn't reached during tree traversal
  /// or neither [node] nor its entire subtree matched the search predicate.
  TreeSearchMatch? matchOf(T node) => matches[node];

  /// Whether [node] has a direct or indirect search match.
  ///
  /// A direct match means the search predicate returned true for [node].
  /// An indirect match means the search predicate returned false for [node],
  /// but it returned true for at least one descendant node in [node]'s subtree.
  bool hasMatch(T node) => matches.containsKey(node);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty.lazy('matches', () => matches))
      ..add(IntProperty('total node count', totalNodeCount))
      ..add(IntProperty('total match count', totalMatchCount));
  }
}

/// Represents the details of a search operation on a tree for a given node.
///
/// This class contains information about whether a node is a match for the
/// search predicate, the number of nodes in the subtree rooted at the node,
/// and the number of nodes in the subtree that match the search predicate.
///
/// See also:
/// * [TreeSearchResult], which holds all matches of a search operation on a
///   tree.
/// * [TreeController.search], which traverses a tree looking for nodes that
///   match the given predicate.
class TreeSearchMatch with Diagnosticable {
  /// Creates a [TreeSearchMatch].
  const TreeSearchMatch({
    this.isDirectMatch = true,
    this.subtreeNodeCount = 0,
    this.subtreeMatchCount = 0,
  });

  /// Whether the node itself is a direct match for the search predicate.
  final bool isDirectMatch;

  /// The number of nodes in the subtree rooted at the node, excluding the root
  /// itself.
  final int subtreeNodeCount;

  /// The number of nodes in the subtree rooted at the node, excluding the root
  /// itself, that match the search predicate.
  final int subtreeMatchCount;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('direct match', isDirectMatch))
      ..add(IntProperty('subtree node count', subtreeNodeCount))
      ..add(IntProperty('subtree match count', subtreeMatchCount));
  }

  @override
  int get hashCode => Object.hash(
        isDirectMatch,
        subtreeNodeCount,
        subtreeMatchCount,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TreeSearchMatch &&
        other.runtimeType == runtimeType &&
        other.isDirectMatch == isDirectMatch &&
        other.subtreeNodeCount == subtreeNodeCount &&
        other.subtreeMatchCount == subtreeMatchCount;
  }
}

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
