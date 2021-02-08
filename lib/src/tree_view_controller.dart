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
  /// Creates a [TreeViewController].
  TreeViewController({
    required this.rootNode,
  }) : assert(rootNode.isRoot, "The rootNode's parent must be null.");

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
    final descendants = removableDescendantsOf(node);
    eventDispatcher.emit(NodeCollapsedEvent(nodes: descendants));
  }

  /// Collapses all nodes.
  /// Only the children of [TreeView.rootNode] will be visible.
  void collapseAll() => collapseNode(rootNode);

  /* HELPER METHODS */

  /// Changes the `isSelected` property of [node] and its subtree
  /// to [state] (defaults to `true`).
  void selectSubtree(TreeNode node, [bool state = true]) {
    subtreeGenerator(node).forEach((n) => n.toggleSelected(state));
  }

  /// Changes the `isEnabled` property of [node] and its subtree
  /// to [state] (defaults to `true`).
  void enableSubtree(TreeNode node, [bool state = true]) {
    subtreeGenerator(node).forEach((n) => n.toggleEnabled(state));
  }

  /// Returns a list of every selected node in the subtree of [startingNode].
  ///
  /// If [startingNode] is null, starts from [rootNode].
  List<TreeNode> selectedNodes(TreeNode? startingNode) {
    return subtreeGenerator(startingNode ?? rootNode)
        .where((n) => n.isSelected)
        .toList(growable: false);
  }

  /// Returns a list of every enabled node in the subtree of [startingNode].
  ///
  /// If [startingNode] is null, starts from [rootNode].
  List<TreeNode> enabledNodes(TreeNode? startingNode) {
    return subtreeGenerator(startingNode ?? rootNode)
        .where((n) => n.isEnabled)
        .toList(growable: false);
  }

  /// Returns a list with every node in the subtree of [node]
  /// that is removable (`depth > 0`), in post order. *(e.g. 3, 2, 1)*
  List<TreeNode> removableDescendantsOf(TreeNode node) {
    return reversedSubtreeGenerator(node)
        .where((node) => node.isRemovable)
        .toList(growable: false);
  }
}
