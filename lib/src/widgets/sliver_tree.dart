import 'package:flutter/material.dart';

import '../foundation/tree_controller.dart';

/// Signature of a widget builder function for tree views.
typedef TreeNodeBuilder<T extends Object> = Widget Function(
  BuildContext context,
  TreeEntry<T> entry,
);

// Examples can assume:
//
// class MyNode {
//   MyNode(this.title) : children = <MyNode>[];
//   String title;
//   List<MyNode> children;
// }
//
// final TreeController<MyNode> treeController = TreeController<MyNode>(
//   root: MyNode('Root'),
//   childrenProvider: (MyNode node) => node.children,
// );

/// A wrapper around [SliverList] that adds basic tree viewing capabilities.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return CustomScrollView(
///     slivers: [
///       SliverTree<MyNode>(
///         controller: treeController,
///         nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
///           ...
///         },
///       ),
///     ],
///   );
/// }
/// ```
///
/// See also:
/// * [AnimatedTreeView], which covers the [CustomScrollView] boilerplate.
/// * [SliverTree], a tree sliver with no custom behaviors.
class SliverTree<T extends Object> extends StatefulWidget {
  /// Creates a [SliverTree].
  const SliverTree({
    super.key,
    required this.controller,
    required this.nodeBuilder,
  });

  /// {@template flutter_fancy_tree_view.SliverTree.controller}
  /// The object responsible for providing access to tree nodes and its states.
  ///
  /// This widget will listen to the notifications of this controller and
  /// rebuild the internal flat represetantion of the tree to make sure the
  /// presented tree view is always up to date.
  /// {@endtemplate}
  final TreeController<T> controller;

  /// {@template flutter_fancy_tree_view.SliverTree.nodeBuilder}
  /// Callback used to map tree nodes into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds,
  /// like the index, level, expansion state, parent, etc.
  /// {@endtemplate}
  final TreeNodeBuilder<T> nodeBuilder;

  @override
  State<SliverTree<T>> createState() => _SliverTreeState<T>();
}

class _SliverTreeState<T extends Object> extends State<SliverTree<T>> {
  List<TreeEntry<T>> _flatTree = const [];

  void _updateFlatTree() {
    final List<TreeEntry<T>> flatTree = [];
    widget.controller.depthFirstTraversal(onTraverse: flatTree.add);
    _flatTree = flatTree;
  }

  void _rebuild() => setState(_updateFlatTree);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _updateFlatTree();
  }

  @override
  void didUpdateWidget(covariant SliverTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _flatTree = const [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _flatTree.length,
        (BuildContext context, int index) {
          return widget.nodeBuilder(context, _flatTree[index]);
        },
      ),
    );
  }
}
