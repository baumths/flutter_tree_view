import 'dart:collection' show HashSet, UnmodifiableSetView;

import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'tree_node.dart' show TreeNode;

/// A simple controller that can be used to dynamically update the state of a
/// tree.
///
/// Whenever this controller notifies its listeners any attached [SliverTree]s
/// will assume that the tree structure changed in some way and will rebuild
/// their internal flat representaton of the tree, showing/hiding the updated
/// nodes (if any).
///
/// The default implementations of [getExpansionState] and [setExpansionState]
/// uses a [Set] to store the expansion state of nodes. This behavior can be
/// changed by extending this class. In the following example each node holds
/// its own expansion state:
///
/// ```dart
/// class MyNode extends TreeNode<T> {
///   bool isExpanded = false;
///   // ...
/// }
///
/// class MyController extends TreeController<MyNode> {
///   @override
///   bool getExpansionState(MyNode node) => node.isExpanded;
///
///   @override
///   void setExpansionState(MyNode node, bool expanded) {
///     node.isExpanded = expanded;
///   }
/// }
/// ```
class TreeController<T extends TreeNode<T>> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// [initiallyExpandedNodes] can be provided to have some nodes already
  /// expanded by default.
  TreeController({Set<T>? initiallyExpandedNodes}) {
    if (initiallyExpandedNodes == null) return;
    _expandedNodesCache.addAll(initiallyExpandedNodes);
  }

  /// The set of nodes that are currently expanded.
  ///
  /// This implies that the default implementations of [getExpansionState] and
  /// [setExpansionState] weren't overriden. Otherwise, will just return a new
  /// empty set.
  UnmodifiableSetView<T> get expandedNodes {
    return UnmodifiableSetView(_expandedNodesCache);
  }

  HashSet<T> get _expandedNodesCache => _expandedNodes ??= HashSet<T>();
  HashSet<T>? _expandedNodes;

  /// The current expansion state of [node].
  ///
  /// If this method returns `true`, the children of [node] should be visible
  /// in tree views.
  bool getExpansionState(T node) => _expandedNodesCache.contains(node);

  /// Updates the expansion state of [node].
  ///
  /// The `bool expanded` parameter represents the **new** expansion state.
  void setExpansionState(T node, bool expanded) {
    if (expanded) {
      _expandedNodesCache.add(node);
    } else {
      _expandedNodesCache.remove(node);
    }
  }

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so that
  /// listeners may handle the updated values.
  ///
  /// Example:
  /// ```dart
  /// class Node extends TreeNode<Node> { ... }
  /// TreeController<Node> controller = ...;
  ///
  /// void addChild(Node parent, Node child) {
  ///   parent.children.add(child);
  ///   controller.rebuild();
  /// }
  ///```
  void rebuild() => notifyListeners();

  void _doExpand(T node) => setExpansionState(node, true);
  void _doCollapse(T node) => setExpansionState(node, false);

  /// Updates the expansion state of [node] to the opposite state and calls
  /// [rebuild].
  void toggleExpansion(T node) {
    setExpansionState(node, !getExpansionState(node));
    rebuild();
  }

  /// Sets the expansion state of [node] to `true` and then calls [rebuild].
  ///
  /// If [node] is already expanded, nothing happens.
  void expand(T node) {
    if (getExpansionState(node)) return;
    _doExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] and every descendant node to `true`,
  /// then calls [rebuild].
  void expandCascading(T node) {
    _doExpand(node);
    node.visitDescendants(_doExpand);
    rebuild();
  }

  /// Walks down the subtrees of [roots] in pre order traversal setting
  /// the expansion state of all nodes to `true` then calls [rebuild].
  void expandAll(Iterable<T> roots) {
    for (final T root in roots) {
      _doExpand(root);
      root.visitDescendants(_doExpand);
    }
    rebuild();
  }

  /// Sets the expansion state of [node] to `false` and then calls [rebuild].
  ///
  /// If [node] is already collapsed, nothing happens.
  void collapse(T node) {
    if (!getExpansionState(node)) return;
    _doCollapse(node);
    rebuild();
  }

  /// Sets the expansion state of [node] and every descendant node to `false`,
  /// then calls [rebuild].
  void collapseCascading(T node) {
    _doCollapse(node);
    node.visitDescendants(_doCollapse);
    rebuild();
  }

  /// Walks down the subtrees of [roots] in pre order traversal setting
  /// the expansion state of all nodes to `false` and calls [rebuild].
  void collapseAll(Iterable<T> roots) {
    for (final T root in roots) {
      _doCollapse(root);
      root.visitDescendants(_doCollapse);
    }
    rebuild();
  }

  /// Walks up the ancestors of [node] setting their expansion state to `true`.
  /// Note: [node] is not expanded by this method.
  ///
  /// This can be used to reveal a hidden node (e.g. when searching for a node
  /// in a search view).
  ///
  /// For this method to work, the [TreeNode.parent] binding must be properly
  /// implemented, which by default just returns `null`.
  void expandPath(T node) {
    node.visitAncestors(_doExpand);
    rebuild();
  }

  @override
  void dispose() {
    _expandedNodes = null;
    super.dispose();
  }
}
