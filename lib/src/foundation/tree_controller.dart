import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'tree_node.dart';

/// A simple controller that can be used to dynamically update the state of a
/// tree.
///
/// When provided to a [TreeView] or [SliverTree], whenever this controller
/// notifies its listeners the [SliverTree] will assume that the tree structure
/// changed in some way and will rebuild its internal flat representaton of the
/// tree, showing/hiding the updated nodes (if any).
class TreeController<T extends TreeNode<T>> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// [TreeController.onExpansionChanged] is required to properly update the
  /// expansion state of tree nodes when using the expand/collapse methods of
  /// this controller.
  TreeController({
    required this.onExpansionChanged,
  });

  /// A callback that should update the expansion state of a tree node when
  /// called.
  ///
  /// The `bool expanded` parameter represents the **new** expansion state.
  ///
  /// The expand and collapse methods of this controller will use this callback
  /// to update the expansion state of nodes when necessary.
  TreeExpansionStateSetter<T> onExpansionChanged;

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so that
  /// listeners can update their flat trees to include the new changes.
  ///
  /// Example:
  /// ```dart
  /// class Node extends TreeNode<Node> {
  ///   @override
  ///   bool isExpanded = false;
  /// }
  ///
  /// TreeController<Node> controller = ...;
  ///
  /// void expand(Node node) {
  ///   node.isExpanded = true;
  ///   controller.rebuild();
  /// }
  ///```
  void rebuild() => notifyListeners();

  /// Updates the expansion state of [node] to the opposite state and calls
  /// [rebuild].
  void toggleExpansion(T node) {
    onExpansionChanged(node, !node.isExpanded);
    rebuild();
  }

  /// Expands [node] and calls [rebuild].
  ///
  /// If [node] is already expanded, nothing happens.
  void expand(T node) {
    if (node.isExpanded) return;
    onExpansionChanged(node, true);
    rebuild();
  }

  /// Walks down the subtree of [node] calling `onExpansionChanged(node, true)`
  /// with [node] and every descendant node, then calls [rebuild].
  void expandCascading(T node) {
    _doExpand(node);
    node.visitDescendants(_doExpand);
    rebuild();
  }

  /// Collapses [node] and calls [rebuild].
  ///
  /// If [node] is already collapsed, nothing happens.
  void collapse(T node) {
    if (!node.isExpanded) return;
    onExpansionChanged(node, false);
    rebuild();
  }

  /// Walks down the subtree of [node] calling `onExpansionChanged(node, false)`
  /// with [node] and every descendant node, then calls [rebuild].
  void collpaseCascading(T node) {
    _doCollapse(node);
    node.visitDescendants(_doCollapse);
    rebuild();
  }

  void _doExpand(T node) => onExpansionChanged(node, true);
  void _doCollapse(T node) => onExpansionChanged(node, false);
}

/// A simple extension on [TreeController] that adds methods that require the
/// `T extends ParentedTreeNode<T>` type bound.
///
/// This extension will only be available for instances of [TreeController] that
/// were created for subclasses of [ParentedTreeNode].
///
/// This enables the possibility to work with [ParentedTreeNode] without having
/// to deal with type bounds.
extension ParentedTreeControllerExtension<T extends ParentedTreeNode<T>>
    on TreeController<T> {
  /// Walks up the path of [node] and calls `onExpansionChanged(node, true)` for
  /// every ancestor node. Note: [node] is not expanded by this method.
  ///
  /// This can be used to reveal a hidden node (e.g. when searching for a node
  /// in a search view).
  void expandPath(T node) {
    node.visitAncestors(_doExpand);
    rebuild();
  }
}
