import 'package:flutter/material.dart';

import '../foundation.dart';
import 'sliver_tree.dart';

/// A highly customizable hierarchy visualization widget.
///
/// Usage:
/// ```dart
/// class Node {
///   Node(this.title) : children = <Node>[];
///   String title;
///   List<Node> chilren;
/// }
///
/// class MyTreeView extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return TreeView<Node>(
///       roots: [Node('Root')],
///       childrenProvider: (Node node) => node.children,
///       nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
///       return MyTreeTile(entry: entry);
///     );
///   }
/// }
///
/// class MyTreeTile extends StatelessWidget {
///   const MyTreeTile({super.key, required this.entry});
///
///   final TreeEntry<Node> entry;
///
///   @override
///   Widget build(BuildContext context) {
///     return TreeIndentation(
///       child: Row(
///         children: [
///           ExpandIcon(
///             key: ValueKey<Node>(entry.node),
///             isExpanded: entry.isExpanded,
///             onPressed: (_) {
///               SliverTree.of<Node>(context).toggleExpansion(entry.node);
///             },
///           ),
///           Flexible(
///             child: Text(entry.node.title),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
///
/// See also:
/// * [SliverTree], which is created internally by [TreeView]. It can be used to
///   create more sophisticated scrolling experiences.
class TreeView<T extends Object> extends BoxScrollView {
  /// Creates a [TreeView].
  const TreeView({
    super.key,
    required this.roots,
    required this.childrenProvider,
    this.treeController,
    required this.nodeBuilder,
    this.transitionBuilder = defaultTreeTransitionBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.linear,
    this.maxNodesToShowWhenAnimating = 50,
    this.rootLevel = defaultTreeRootLevel,
    super.padding,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  });

  /// The roots of the tree.
  ///
  /// These nodes are used as a starting point to build the flat representation
  /// of the tree.
  final Iterable<T> roots;

  /// {@macro flutter_fancy_tree_view.SliverTree.childrenProvider}
  final ChildrenProvider<T> childrenProvider;

  /// An object that can be used to control the state of the tree.
  ///
  /// Whenever this controller notifies its listeners, the internal flat
  /// representation of the tree will be rebuilt.
  final TreeController<T>? treeController;

  /// Callback used to map your data into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds.
  final TreeNodeBuilder<T> nodeBuilder;

  /// A widget builder used to apply a transition to the expansion state changes
  /// of a node subtree when animations are enabled.
  ///
  /// See also:
  ///
  /// * [defaultTreeTransitionBuilder] which uses a [SizeTransition].
  final TreeTransitionBuilder transitionBuilder;

  /// The default duration to use when animating the expand/collapse operations.
  ///
  /// Provide an [animationDuration] of `Duration.zero` to disable animations.
  ///
  /// Defaults to `Duration(milliseconds: 300)`.
  final Duration animationDuration;

  /// The default curve to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Curves.linear`.
  final Curve animationCurve;

  /// {@macro flutter_fancy_tree_view.SliverTree.maxNodesToShowWhenAnimating}
  final int maxNodesToShowWhenAnimating;

  /// {@macro flutter_fancy_tree_view.SliverTree.rootLevel}
  final int rootLevel;
  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverTree<T>(
      roots: roots,
      childrenProvider: childrenProvider,
      controller: treeController,
      nodeBuilder: nodeBuilder,
      transitionBuilder: transitionBuilder,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      maxNodesToShowWhenAnimating: maxNodesToShowWhenAnimating,
      rootLevel: rootLevel,
    );
  }
}
