import 'internal.dart';

/// Callback for interacting with nodes.
typedef TreeViewCallback = void Function(TreeNode node);

/// Callback used to animate the removal of nodes.
typedef RemoveNodeBuilder = Widget Function(
  TreeNode node,
  Animation<double> animation,
);

/// Callback to build a widget for [TreeNode].
typedef NodeBuilder = Widget Function(BuildContext context, TreeNode node);

/// Yields every descendant in the subtree of [node]. In Breadth first traversal.
///
/// If [filter] is not null, yields only the descendants that match filter.
Iterable<TreeNode> subtreeGenerator(
  TreeNode node, [
  bool Function(TreeNode)? filter,
]) sync* {
  for (final child in node.children) {
    if (filter?.call(child) ?? true) {
      yield child;
    }

    if (child.hasChildren) {
      yield* subtreeGenerator(child, filter);
    }
  }
}
