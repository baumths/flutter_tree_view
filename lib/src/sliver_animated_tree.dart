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
///         duration: const Duration(milliseconds, 300),
///         curve: Curves.linear,
///         maxNodesToShowWhenAnimating: 50,
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

  /// {@template flutter_fancy_tree_view.SliverAnimatedTree.maxNodesToShowWhenAnimating}
  /// The amount of nodes that are going to be shown on an animating subtree.
  ///
  /// Must be greater than `0`.
  ///
  /// When animating the expand/collapse state changes, all descendant nodes
  /// whose visibility will change are rendered along with the toggled node,
  /// i.e. a [Column] is used, therefore rendering the entire subtree regardless
  /// of being a "lazy" rendered view.
  ///
  /// This value can be used to limit how many nodes are actually rendered
  /// during the animation, since there could be cases where not all widgets
  /// are visible due to scroll offsets.
  ///
  /// Defaults to `50`.
  /// {@endtemplate}
  final int maxNodesToShowWhenAnimating;

  @override
  State<SliverAnimatedTree<T>> createState() => _SliverAnimatedTreeState<T>();
}

class _SliverAnimatedTreeState<T extends Object>
    extends State<SliverAnimatedTree<T>> {
  Map<T, bool> get _expansionStates => _expansionStatesCache ??= <T, bool>{};
  Map<T, bool>? _expansionStatesCache;

  List<TreeEntry<T>> _flatTree = const [];

  void _updateFlatTree() {
    final Map<T, bool> oldExpansionStates = Map<T, bool>.of(_expansionStates);

    final Map<T, bool> currentExpansionStates = <T, bool>{};
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];

    final Visitor<TreeEntry<T>> onTraverse;

    if (widget.duration == Duration.zero) {
      onTraverse = (TreeEntry<T> entry) {
        flatTree.add(entry);
        currentExpansionStates[entry.node] = entry.isExpanded;
      };
    } else {
      onTraverse = (TreeEntry<T> entry) {
        flatTree.add(entry);
        currentExpansionStates[entry.node] = entry.isExpanded;

        final bool? previousState = oldExpansionStates[entry.node];
        if (previousState != null && previousState != entry.isExpanded) {
          _animatingNodes.add(entry.node);
        }
      };
    }

    widget.controller.depthFirstTraversal(
      onTraverse: onTraverse,
      descendCondition: (TreeEntry<T> entry) {
        if (_animatingNodes.contains(entry.node)) {
          // The descendants of a node that is animating are not included in
          // the flattened tree since those nodes are going to be rendered in
          // a single list item.
          return false;
        }
        return entry.isExpanded;
      },
    );

    _flatTree = flatTree;
    _expansionStatesCache = currentExpansionStates;
  }

  void _rebuild() => setState(_updateFlatTree);

  final Set<T> _animatingNodes = <T>{};

  void _onAnimationComplete(T node) {
    _animatingNodes.remove(node);
    _rebuild();
  }

  List<TreeEntry<T>> _buildSubtree(TreeEntry<T> entry) {
    final List<TreeEntry<T>> subtree = <TreeEntry<T>>[];
    widget.controller.depthFirstTraversal(
      rootEntry: entry,
      onTraverse: subtree.add,
    );
    if (subtree.length > widget.maxNodesToShowWhenAnimating) {
      return subtree.sublist(0, widget.maxNodesToShowWhenAnimating);
    }
    return subtree;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _updateFlatTree();
  }

  @override
  void didUpdateWidget(covariant SliverAnimatedTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
      _updateFlatTree();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _animatingNodes.clear();
    _flatTree = const [];
    _expansionStatesCache = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: _flatTree.length,
        (BuildContext context, int index) {
          final TreeEntry<T> entry = _flatTree[index];
          return _TreeEntry<T>(
            key: _SaltedTreeNodeKey(entry.node),
            entry: entry,
            nodeBuilder: widget.nodeBuilder,
            buildFlatSubtree: _buildSubtree,
            transitionBuilder: widget.transitionBuilder,
            onAnimationComplete: _onAnimationComplete,
            curve: widget.curve,
            duration: widget.duration,
            showSubtree: _animatingNodes.contains(entry.node),
          );
        },
      ),
    );
  }
}

class _SaltedTreeNodeKey extends GlobalObjectKey {
  const _SaltedTreeNodeKey(super.value);
}

typedef _FlatSubtreeBuilder<T extends Object> = List<TreeEntry<T>> Function(
  TreeEntry<T> virtualRoot,
);

class _TreeEntry<T extends Object> extends StatefulWidget {
  const _TreeEntry({
    super.key,
    required this.entry,
    required this.nodeBuilder,
    required this.buildFlatSubtree,
    required this.transitionBuilder,
    required this.onAnimationComplete,
    required this.curve,
    required this.duration,
    required this.showSubtree,
  });

  final TreeEntry<T> entry;
  final TreeNodeBuilder<T> nodeBuilder;
  final _FlatSubtreeBuilder<T> buildFlatSubtree;

  final TreeTransitionBuilder transitionBuilder;
  final ValueSetter<T> onAnimationComplete;
  final Curve curve;
  final Duration duration;
  final bool showSubtree;

  @override
  State<_TreeEntry<T>> createState() => _TreeEntryState<T>();
}

class _TreeEntryState<T extends Object> extends State<_TreeEntry<T>>
    with SingleTickerProviderStateMixin {
  TreeEntry<T> get entry => widget.entry;
  T get node => entry.node;

  late final AnimationController animationController;
  late final CurveTween curveTween;

  bool isExpanded = false;

  void onAnimationComplete() {
    widget.onAnimationComplete(node);
    if (!mounted) return;
    setState(() {});
  }

  void expand() {
    // Sometimes when [isExpanded] changes and [widget.shouldAnimate] is set to
    // `false`, the animation value is not reset, then later when a subsequent
    // animation starts, the controller is already completed and no animation
    // is played at all.
    final double? from = animationController.value == 1.0 ? 0.0 : null;
    animationController.forward(from: from).whenComplete(onAnimationComplete);
  }

  void collapse() {
    // Sometimes when [isExpanded] changes and [widget.shouldAnimate] is set to
    // `false`, the animation value is not reset, then later when a subsequent
    // animation starts, the controller is already completed and no animation
    // is played at all.
    final double? from = animationController.value == 0.0 ? 1.0 : null;
    animationController.reverse(from: from).whenComplete(onAnimationComplete);
  }

  @override
  void initState() {
    super.initState();
    isExpanded = entry.isExpanded;

    curveTween = CurveTween(curve: widget.curve);
    animationController = AnimationController(
      vsync: this,
      value: isExpanded ? 1.0 : 0.0,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(covariant _TreeEntry<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    curveTween.curve = widget.curve;
    animationController.duration = widget.duration;

    final bool expansionState = entry.isExpanded;

    if (isExpanded != expansionState) {
      isExpanded = expansionState;

      if (widget.showSubtree) {
        isExpanded ? expand() : collapse();
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget tile = widget.nodeBuilder(context, entry);

    late final Widget subtree = _Subtree<T>(
      virtualRoot: entry,
      nodeBuilder: widget.nodeBuilder,
      buildFlatSubtree: widget.buildFlatSubtree,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        if (widget.showSubtree && animationController.isAnimating)
          widget.transitionBuilder(
            context,
            subtree,
            animationController.drive(curveTween),
          ),
      ],
    );
  }
}

class _Subtree<T extends Object> extends StatefulWidget {
  const _Subtree({
    super.key,
    required this.virtualRoot,
    required this.nodeBuilder,
    required this.buildFlatSubtree,
  });

  final TreeEntry<T> virtualRoot;
  final TreeNodeBuilder<T> nodeBuilder;
  final _FlatSubtreeBuilder<T> buildFlatSubtree;

  @override
  State<_Subtree<T>> createState() => _SubtreeState<T>();
}

class _SubtreeState<T extends Object> extends State<_Subtree<T>> {
  late List<TreeEntry<T>> virtualEntries;

  @override
  void initState() {
    super.initState();
    virtualEntries = widget.buildFlatSubtree(widget.virtualRoot);
  }

  @override
  void dispose() {
    virtualEntries = const [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final TreeEntry<T> virtualEntry in virtualEntries)
            widget.nodeBuilder(context, virtualEntry),
        ],
      ),
    );
  }
}
