import 'internal.dart';

/// Controller for managing the nodes that compose [TreeView].
///
/// This controller was extracted from [TreeView] for use cases where you
/// need to toggle/find a node from outside the [TreeView] widget subtree.
/// Makes it easy to pass the controller down the widget tree
/// through dependency injection (like the Provider package).
///
/// Make sure you call [TreeViewController.dispose] to release resources
/// once the controller is not needed anymore.
class TreeViewController {
  /// Constructor for [TreeViewController].
  TreeViewController({required this.rootNode});

  /// The [TreeNode] that will store all top level nodes.
  final TreeNode rootNode;

  final eventDispatcher = TreeViewEventDispatcher();

  /* EXPAND METHODS */

  /// Expands a single node.
  void expandNode(TreeNode node) {
    if (node.isLeaf || node.isExpanded) return;
    node.expand();
    eventDispatcher.emit(NodeExpandedEvent(node: node));
  }

  /// Expands [node] and every descendant node.
  void expandSubtree(TreeNode node) {
    subtreeGenerator(node).forEach(expandNode);
  }

  /// Expands every node in the tree.
  void expandAll() => expandSubtree(rootNode);

  /* COLLAPSE METHODS */

  /// Collapses [node] and its subtree.
  void collapseNode(TreeNode node) {
    if (node.isLeaf || !node.isExpanded) return;
    node.collapse();

    final subtree = subtreeGenerator(node)
        .where((n) => n.isRemovable && (n.isLeaf || !n.isExpanded))
        .toList(growable: false);
    eventDispatcher.emit(NodeCollapsedEvent(nodes: subtree));
  }

  /// Collapses all nodes.
  /// Only the children of [TreeView.rootNode] will be visible.
  void collapseAll() => collapseNode(rootNode);

  /// Release resources.
  void dispose() => eventDispatcher.dispose();
}
