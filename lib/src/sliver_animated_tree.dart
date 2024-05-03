import 'package:flutter/material.dart';

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

/// Signature for a function that takes a widget and an animation to apply
/// transitions if needed.
typedef TreeTransitionBuilder = Widget Function(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

/// The default transition builder used by [SliverTree] to animate the expansion
/// state changes of a tree node.
///
/// Wraps [child] in a [SizeTransition].
Widget defaultTreeTransitionBuilder(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  return SizeTransition(sizeFactor: animation, child: child);
}

/// A wrapper around [SliverList] that adds tree viewing capabilities with
/// support for automatic expand and collapse animations.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return CustomScrollView(
///     slivers: [
///       SliverAnimatedTree<Node>(
///         controller: treeController,
///         duration: const Duration(milliseconds: 300),
///         curve: Curves.linear,
///         nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
///           ...
///         },
///       ),
///     ],
///   );
/// }
/// ```
///
/// This widget will listen to [controller] and rebuild the inner flat
/// representation of the tree keeping a map of the expansion state of tree
/// nodes to then check if the cached value is different from the current
/// node expansion state when visiting that node during flattening and will
/// mark it to be animated.
/// When a node is marked to animate, its subtree won't be traversed during
/// flattening to later on be rendered in the same list item of the subtree
/// root's node widget. Once the animation completes, the node is removed
/// from the set of animating nodes and the tree is flattened again so the
/// animating subtree can go back to being one list item per node.
///
/// See also:
/// * [AnimatedTreeView], which covers the [CustomScrollView] boilerplate.
/// * [SliverTree], a tree sliver with no custom behaviors.
class SliverAnimatedTree<T extends Object> extends SliverTree<T> {
  /// Creates a [SliverAnimatedTree].
  const SliverAnimatedTree({
    super.key,
    required super.controller,
    required super.nodeBuilder,
    this.transitionBuilder = defaultTreeTransitionBuilder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
    @Deprecated('Not needed by the new animation implementation')
    this.maxNodesToShowWhenAnimating = 50,
  }) : assert(maxNodesToShowWhenAnimating > 0);

  /// {@template flutter_fancy_tree_view.SliverAnimatedTree.transitionBuilder}
  /// A widget builder used to apply a transition to the expansion state changes
  /// of a node subtree when animations are enabled.
  ///
  /// See also:
  ///
  /// * [defaultTreeTransitionBuilder] which uses a [SizeTransition].
  /// {@endtemplate}
  final TreeTransitionBuilder transitionBuilder;

  /// {@template flutter_fancy_tree_view.SliverAnimatedTree.duration}
  /// The default duration to use when animating the expand/collapse operations.
  ///
  /// Provide a [duration] of `Duration.zero` to disable animations.
  ///
  /// Defaults to `Duration(milliseconds: 300)`.
  /// {@endtemplate}
  final Duration duration;

  /// {@template flutter_fancy_tree_view.SliverAnimatedTree.curve}
  /// The default curve to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Curves.linear`.
  /// {@endtemplate}
  final Curve curve;

  /// @no-doc
  @Deprecated('Not needed by the new animation implementation')
  final int maxNodesToShowWhenAnimating;

  @override
  State<SliverAnimatedTree<T>> createState() => _SliverAnimatedTreeState<T>();
}

class _SliverAnimatedTreeState<T extends Object>
    extends State<SliverAnimatedTree<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  List<TreeEntry<T>> _flatTree = const [];

  void _rebuild() {
    setState(() {
      final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
      widget.controller.depthFirstTraversal(onTraverse: flatTree.add);
      _flatTree = flatTree;
    });
  }

  void _animatedRebuild() {
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
    final List<int> indicesAnimatingIn = <int>[];
    final Map<T, TreeEntry<T>> oldEntries = <T, TreeEntry<T>>{
      for (final TreeEntry<T> entry in _flatTree.reversed) entry.node: entry,
    };

    widget.controller.depthFirstTraversal(onTraverse: (TreeEntry<T> entry) {
      flatTree.add(entry);

      if (oldEntries.remove(entry.node) == null) {
        indicesAnimatingIn.add(entry.index);
      }
    });

    for (final TreeEntry<T> entry in oldEntries.values) {
      _listKey.currentState?.removeItem(
        duration: widget.duration,
        entry.index,
        (BuildContext context, Animation<double> animation) {
          return widget.transitionBuilder(
            context,
            widget.nodeBuilder(context, entry),
            animation,
          );
        },
      );
    }

    setState(() {
      _flatTree = flatTree;
    });

    for (final int index in indicesAnimatingIn) {
      _listKey.currentState?.insertItem(index, duration: widget.duration);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_animatedRebuild);
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant SliverAnimatedTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_animatedRebuild);
      widget.controller.addListener(_animatedRebuild);
      _rebuild();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_animatedRebuild);
    _flatTree = const [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeViewScope<T>(
      controller: widget.controller,
      child: SliverAnimatedList(
        key: _listKey,
        initialItemCount: _flatTree.length,
        itemBuilder: (
          BuildContext context,
          int index,
          Animation<double> animation,
        ) {
          return widget.transitionBuilder(
            context,
            widget.nodeBuilder(context, _flatTree[index]),
            CurvedAnimation(parent: animation, curve: widget.curve),
          );
        },
      ),
    );
  }
}
