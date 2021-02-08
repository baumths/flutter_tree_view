import 'internal.dart';

// * ~~~~~~~~~~ TYPE DEFS ~~~~~~~~~~ *

/// Callback for interacting with nodes.
typedef TreeViewCallback = void Function(TreeNode node);

/// Callback for notifying [TreeView] when a node is expanded.
typedef NodeExpandedCallback = void Function(int index);

/// Callback for notifying [TreeView] when a node is collapsed.
typedef NodeCollapsedCallback = void Function(int index, TreeNode node);

/// Callback used to animate the removal of nodes.
typedef RemoveNodeBuilder = Widget Function(
  TreeNode node,
  Animation<double> animation,
);

/// Callback to build a widget for [TreeNode].
typedef NodeBuilder = NodeWidget Function(BuildContext context, TreeNode node);

// * ~~~~~~~~~~ HELPER FUNCTIONS ~~~~~~~~~~ *

/// Yields every descendant in the subtree of [node]. In Breadth first traversal.
Iterable<TreeNode> subtreeGenerator(TreeNode node) sync* {
  for (final child in node.children) {
    yield child;
    if (child.hasChildren) yield* subtreeGenerator(child);
  }
}

/// Same as [subtreeGenerator] but with nullable return, useful when
/// filtering nodes to use `orElse: () => null` when no node was found.
Iterable<TreeNode?> nullableSubtreeGenerator(TreeNode node) sync* {
  for (final child in node.children) {
    yield child;
    if (child.hasChildren) yield* nullableSubtreeGenerator(child);
  }
}

/// Yields every descendant in the subtree of [node]. In post-order traversal.
Iterable<TreeNode> reversedSubtreeGenerator(TreeNode node) sync* {
  for (final child in node.children.reversed) {
    if (child.hasChildren) yield* reversedSubtreeGenerator(child);
    yield child;
  }
}
