import 'package:flutter/material.dart';

import 'sliver_animated_tree.dart';
import 'sliver_tree.dart';
import 'tree_controller.dart';

// Examples can assume:
//
// class Node {
//   Node(this.children);
//   List<Node> children;
// }
//
// final TreeController<Node> treeController = TreeController<Node>(
//   root: <Node>[
//     Node(<Node>[]),
//   ],
//   childrenProvider: (Node node) => node.children,
// );

/// A widget used to visualize tree hierarchies.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return TreeView<Node>(
///     treeController: treeController,
///     nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
///       ...
///     },
///   );
/// }
/// ```
///
/// See also:
/// * [SliverTree], which is created internally by [TreeView]. It can
///   be used to create more sophisticated scrolling experiences.
/// * [AnimatedTreeView], a version of this widget that animates the expand and
///   collapse tree operations.
class TreeView<T extends Object> extends BoxScrollView {
  /// Creates a [TreeView].
  const TreeView({
    super.key,
    required this.treeController,
    required this.nodeBuilder,
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

  /// {@macro flutter_fancy_tree_view.SliverTree.controller}
  final TreeController<T> treeController;

  /// {@macro flutter_fancy_tree_view.SliverTree.nodeBuilder}
  final TreeNodeBuilder<T> nodeBuilder;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverTree<T>(
      controller: treeController,
      nodeBuilder: nodeBuilder,
    );
  }
}

/// A [TreeView] that animates the expansion state changes of tree nodes.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return AnimatedTreeView<Node>(
///     treeController: treeController,
///     duration: const Duration(milliseconds, 300),
///     curve: Curves.linear,
///     maxNodesToShowWhenAnimating: 50,
///     transitionBuilder: (BuildContext context, Widget child, Animation<double> animation) {
///       return FadeTransition(
///         opacity: animation,
///         child: SizeTransition(
///           sizeFactor: animation,
///           child: child,
///         ),
///       );
///     },
///     nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
///       ...
///     },
///   );
/// }
/// ```
///
/// See also:
/// * [SliverAnimatedTree], which is created internally by [AnimatedTreeView].
///   It can be used to create more sophisticated scrolling experiences.
/// * [TreeView], a version of this widget that has no custom behaviors.
class AnimatedTreeView<T extends Object> extends TreeView<T> {
  /// Creates a [TreeView].
  const AnimatedTreeView({
    super.key,
    required super.treeController,
    required super.nodeBuilder,
    this.transitionBuilder = defaultTreeTransitionBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    this.maxNodesToShowWhenAnimating = 50,
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

  /// {@macro flutter_fancy_tree_view.SliverAnimatedTree.transitionBuilder}
  final TreeTransitionBuilder transitionBuilder;

  /// {@macro flutter_fancy_tree_view.SliverAnimatedTree.duration}
  final Duration duration;

  /// {@macro flutter_fancy_tree_view.SliverAnimatedTree.curve}
  final Curve curve;

  /// {@macro flutter_fancy_tree_view.SliverAnimatedTree.maxNodesToShowWhenAnimating}
  final int maxNodesToShowWhenAnimating;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverAnimatedTree<T>(
      controller: treeController,
      nodeBuilder: nodeBuilder,
      duration: duration,
      curve: curve,
      maxNodesToShowWhenAnimating: maxNodesToShowWhenAnimating,
    );
  }
}
