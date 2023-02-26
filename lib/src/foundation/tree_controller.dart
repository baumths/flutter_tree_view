import 'package:flutter/foundation.dart';

import 'tree_expansion_state.dart';

/// The default level used for root nodes when flattening the tree.
const int defaultTreeRootLevel = 0;

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
/// Used when traversing a tree to decide when to descend into the children of
/// the given node.
typedef DescendCondition<T> = bool Function(T node);

/// A controller used to dynamically manage the state of a tree.
///
/// Whenever this controller notifies its listeners any attached tree views
/// will assume that the tree structure changed in some way and will rebuild
/// their internal flat representaton of the tree, showing/hiding the updated
/// nodes (if any).
///
/// Usage:
/// ```dart
/// class MyNode {
///   MyNode(this.title) : children = <MyNode>[];
///   String title;
///   List<MyNode> children;
/// }
///
/// final MyNode root = MyNode('Root');
/// final TreeController<MyNode> treeController = TreeController<MyNode>(
///   root: root,
///   childrenProvider: (MyNode node) => node.children,
/// );
/// ```
class TreeController<T extends Object> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// The [roots] parameter should contain all nodes that occupy the level `0`
  /// of the tree, these nodes are going to be used as a starting point when
  /// traversing the tree and building tree views.
  ///
  /// [expansionState], the tree nodes expansion state cache, when absent,
  /// defaults to [TreeExpansionStateSet] which will store expanded nodes in
  /// a [Set] and call [Set.contains] to check if a node is expanded.
  TreeController({
    required Iterable<T> roots,
    required this.childrenProvider,
    TreeExpansionState<T>? expansionState,
  })  : _roots = roots,
        _expansionState = expansionState ?? TreeExpansionStateSet<T>();

  /// The roots of the tree.
  ///
  /// These nodes are used as a starting point when traversing the tree.
  Iterable<T> get roots => _roots;
  Iterable<T> _roots;
  set roots(Iterable<T> node) {
    if (node == _roots) return;
    _roots = node;
    rebuild();
  }

  /// A callback used when building the flat representation of the tree to get
  /// the direct children of the tree node passed to it.
  ///
  /// Avoid doing heavy computations in this callback since it is going to be
  /// called a lot when traversing the tree.
  ///
  /// Do not attempt to load the children of a node in this callback as it would
  /// significantly slow down tree traversal which might couse ui jank. Prefer
  /// doing such operations on a user action (e.g. a button press).
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
  final ChildrenProvider<T> childrenProvider;

  /// The tree nodes expansion state cache.
  ///
  /// When not provided, defaults to [TreeExpansionStateSet].
  TreeExpansionState<T> get expansionState => _expansionState;
  TreeExpansionState<T> _expansionState;
  set expansionState(TreeExpansionState<T> state) {
    if (_expansionState == state) return;
    _expansionState = state;
    rebuild();
  }

  /// The current expansion state of [node] stored in [expansionState].
  ///
  /// This method delegates its call to [TreeExpansionState.get].
  bool isExpanded(T node) => expansionState.get(node);

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so that
  /// listeners may handle the updated values.
  /// Most methods of this controller (like expand, collapse, etc.) already call
  /// [rebuild] inplicitly.
  ///
  /// Example:
  /// ```dart
  /// class Node {
  ///   List<Node> children;
  /// }
  /// TreeController<Node> controller = ...;
  ///
  /// void addChildren(Node parent, Iterable<Node> children) {
  ///   parent.children.addAll(children);
  ///   controller.rebuild();
  /// }
  ///```
  void rebuild() => notifyListeners();

  void _doCollapse(T node) => expansionState.set(node, false);
  void _doExpand(T node) => expansionState.set(node, true);

  /// Updates the expansion state of [node] to the opposite state, then calls
  /// [rebuild].
  void toggleExpansion(T node) {
    isExpanded(node) ? _doCollapse(node) : _doExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `true`, then calls [rebuild].
  ///
  /// If [node] is already expanded, nothing happens.
  void expand(T node) {
    if (isExpanded(node)) return;
    _doExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `false`, then calls [rebuild].
  ///
  /// If [node] is already collapsed, nothing happens.
  void collapse(T node) {
    if (!isExpanded(node)) return;
    _doCollapse(node);
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
    _applyCascadingAction(nodes, _doExpand);
    rebuild();
  }

  /// Traverses the subtrees of [nodes] in depth first order collapsing every
  /// visited node, then calls [rebuild].
  void collapseCascading(Iterable<T> nodes) {
    _applyCascadingAction(nodes, _doCollapse);
    rebuild();
  }

  /// Walks up the ancestors of [node] setting their expansion state to `true`.
  /// Note: [node] is not expanded by this method.
  ///
  /// This can be used to reveal a hidden node (e.g. when searching for a node
  /// in a search view).
  ///
  /// [parentProvider] should return the direct parent of the given node or
  /// `null` if the root node is reached, this callback is used to traverse the
  /// ancestors of [node].
  void expandPath(T node, ParentProvider<T> parentProvider) {
    T? current = parentProvider(node);

    while (current != null) {
      _doExpand(current);
      current = parentProvider(current);
    }

    rebuild();
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
        descendCondition ?? (TreeEntry<T> entry) => entry.isExpanded;

    int treeIndex = 0;

    void createTreeEntriesRecursively({
      required TreeEntry<T>? parent,
      required Iterable<T> nodes,
      required int level,
    }) {
      TreeEntry<T>? entry;

      for (final T node in nodes) {
        entry = TreeEntry<T>(
          node: node,
          index: treeIndex++,
          isExpanded: expansionState.get(node),
          level: level,
          parent: parent,
        );

        onTraverse(entry);

        late final Iterable<T> children = childrenProvider(node);

        if (shouldDescend(entry) && children.isNotEmpty) {
          entry._hasChildren = true;
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
        level: defaultTreeRootLevel,
      );
    }
  }
}

/// Used to store useful information about [node] in a tree.
///
/// Instances of this class are short lived, created by [TreeController] when
/// traversing the tree; each tree traversal creates a new [TreeEntry] for
/// each tree node with up to date values.
///
/// To make sure that tree views are always up to date make sure to call
/// [TreeController.rebuild] to notify its listeners that the tree structure
/// changed in some way and they should update their cached states.
class TreeEntry<T extends Object> with Diagnosticable {
  /// Creates a [TreeEntry].
  TreeEntry({
    required this.parent,
    required this.node,
    required this.index,
    required this.isExpanded,
    required this.level,
    bool hasChildren = false,
    bool hasNextSibling = true,
    this.unreachableAncestorLevelsWithVerticalLines,
  })  : _hasChildren = hasChildren,
        _hasNextSibling = hasNextSibling;

  /// The direct parent of [node] on the tree.
  final TreeEntry<T>? parent;

  /// The tree node that originated this entry.
  final T node;

  /// The index of [node] in the flat tree list that originated this entry.
  final int index;

  /// The expansion state of [node].
  ///
  /// This value may change since this entry was created.
  final bool isExpanded;

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

  /// Whether this node has any child nodes.
  ///
  /// This value may not represent the truth as [node]'s children may have
  /// changed since this entry was crated.
  bool get hasChildren => _hasChildren;
  bool _hasChildren;

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
  /// ├─ Child <- `hasNextSibling = true`
  /// ├─ Child <- `hasNextSibling = true`
  /// └─ Child <- `hasNextSibling = false`
  bool get hasNextSibling => _hasNextSibling;
  bool _hasNextSibling;

  /// Whether this entry should skip indenting and painting.
  ///
  /// Nodes at level 0 or less have no decoration nor indent by default.
  bool get skipIndentAndPaint => level <= 0;

  /// Aditional ancestor levels that should paint vertical lines.
  ///
  /// Used when painting lines for this entry when it is virtually detached
  /// from the main tree but still needs to paint the lines that connect to it.
  ///
  /// [SliverAnimatedTree] uses this property when animating the expand and
  /// collapse operations of tree nodes.
  final Iterable<int>? unreachableAncestorLevelsWithVerticalLines;

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
