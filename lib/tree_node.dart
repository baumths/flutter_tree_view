import 'package:flutter/foundation.dart' show optionalTypeArgs;

import 'src/foundation/tree.dart';

export 'flutter_fancy_tree_view.dart';

/// A simple object that can be used with [Tree] to compose a tree for
/// a [TreeView].
///
/// Take a look at [TreeNode.createTree] which handles the boilerplate of the
/// [Tree] <-> [TreeNode] relationship.
///
/// Only use this class on really simple usecases. It's recommended to create
/// concrete "node" model and [Tree] implementation.
@optionalTypeArgs
class TreeNode<T extends Object?> {
  static int _autoIncrementedId = 0;

  /// Creates a [TreeNode] with an integer [id] that is automatically
  /// incremented when this constructor is called.
  ///
  /// The automatically incremented integer lives in a private static variable
  /// of the [TreeNode] class.
  TreeNode({
    this.data,
    this.isExpanded = false,
    List<TreeNode<T>>? children,
  })  : id = _autoIncrementedId++,
        children = children ?? <TreeNode<T>>[];

  /// Creates a [TreeNode] from a specific id.
  TreeNode.fromId({
    required this.id,
    this.data,
    this.isExpanded = false,
    List<TreeNode<T>>? children,
  }) : children = children ?? <TreeNode<T>>[];

  /// Convenient static method that creates a [Tree] covering the
  /// [Tree] <-> [TreeNode] relationship boilerplate.
  ///
  /// Example:
  ///
  /// ```dart
  /// final Tree<TreeNode> tree = TreeNode.createTree(
  ///   roots: <TreeNode<String>>[
  ///     TreeNode(
  ///       data: 'Root 1',
  ///       children: [
  ///         TreeNode(data: 'Node 1-1'),
  ///       ],
  ///     ),
  ///     TreeNode(
  ///       data: 'Root 2',
  ///       children: [
  ///         TreeNode(data: 'Node 2-1')
  ///       ],
  ///     ),
  ///     TreeNode(data: 'Root 3'),
  ///   ],
  /// );
  /// ```
  static Tree<TreeNode<T>> createTree<T extends Object>({
    required List<TreeNode<T>> roots,
  }) {
    return _NodeTree<T>(roots);
  }

  /// A unique id for this node.
  final Object id;

  /// Any additional data that could be moved around with this node.
  final T? data;

  /// The current expansion state of this node, used to show/hide node's
  /// descendants on the tree.
  bool isExpanded;

  /// The direct children of this node on the tree.
  final List<TreeNode<T>> children;
}

class _NodeTree<T extends Object> extends Tree<TreeNode<T>> {
  const _NodeTree(this.roots);

  @override
  final List<TreeNode<T>> roots;

  @override
  Object getId(TreeNode<T> node) => node.id;

  @override
  List<TreeNode<T>> getChildren(TreeNode<T>? node) => node?.children ?? roots;

  @override
  bool getExpansionState(TreeNode<T> node) => node.isExpanded;

  @override
  void setExpansionState(TreeNode<T> node, bool expanded) {
    node.isExpanded = expanded;
  }
}
