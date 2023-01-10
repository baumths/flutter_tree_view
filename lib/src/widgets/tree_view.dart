import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import '../foundation.dart';
import 'sliver_tree.dart';

/// A highly customizable hierarchy visualization widget.
///
/// See also:
///
/// * [SliverTree], which is created internally by [TreeView]. It can be used to
///   create more sophisticated scrolling experiences.
class TreeView<T extends Object> extends StatelessWidget {
  /// Creates a [TreeView].
  const TreeView({
    super.key,
    required this.controller,
    required this.nodeBuilder,
    this.transitionBuilder = defaultTreeTransitionBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.linear,
    this.maxNodesToShowWhenAnimating = 50,
    this.rootLevel = defaultTreeRootLevel,
    this.padding,
    this.scrollController,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.shrinkWrap = false,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  /// The controller responsible for providing the tree hierarchy and expansion
  /// state of tree nodes.
  final TreeController<T> controller;

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

  /// The amount of space by which to inset the tree contents.
  ///
  /// It defaults to `EdgeInsets.zero`.
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.shadow.scrollBehavior}
  ///
  /// [ScrollBehavior]s also provide [ScrollPhysics]. If an explicit
  /// [ScrollPhysics] is provided in [physics], it will take precedence,
  /// followed by [scrollBehavior], and then the inherited ancestor
  /// [ScrollBehavior].
  final ScrollBehavior? scrollBehavior;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// The number of children that will contribute semantic information.
  ///
  /// Some subtypes of [ScrollView] can infer this value automatically. For
  /// example [ListView] will use the number of widgets in the child list,
  /// while the [ListView.separated] constructor will use half that amount.
  ///
  /// For [CustomScrollView] and other types which do not receive a builder
  /// or list of widgets, the child count must be explicitly provided. If the
  /// number is unknown or unbounded this should be left unset or set to null.
  ///
  /// See also:
  ///
  ///  * [SemanticsConfiguration.scrollChildCount], the corresponding semantics
  ///    property.
  final int? semanticChildCount;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      reverse: false,
      controller: scrollController,
      primary: primary,
      physics: physics,
      scrollBehavior: scrollBehavior,
      shrinkWrap: shrinkWrap,
      cacheExtent: cacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      slivers: [
        SliverPadding(
          padding: padding ?? EdgeInsets.zero,
          sliver: SliverTree<T>(
            controller: controller,
            nodeBuilder: nodeBuilder,
            transitionBuilder: transitionBuilder,
            animationDuration: animationDuration,
            animationCurve: animationCurve,
            maxNodesToShowWhenAnimating: maxNodesToShowWhenAnimating,
            rootLevel: rootLevel,
          ),
        ),
      ],
    );
  }
}
