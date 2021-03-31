import 'internal.dart';

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

/// Returns a List containing the path from [node] to the root node.
///
/// Includes root [first] and `node [last]`. [root, child, grandChild, ..., `node`]
Iterable<TreeNode> findPathFromRoot(TreeNode node) sync* {
  if (node.parent != null) yield* findPathFromRoot(node.parent!);
  yield node;
}
