import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import '../foundation.dart';
import 'sliver_tree.dart';

/// A simple and highly customizable hierarchy visualization widget.
///
/// See also:
///
/// * [SliverTree], which is created internally by [TreeView]. It can be used to
///   create more sophisticated scrolling experineces.
class TreeView<T extends TreeNode<T>> extends StatelessWidget {
  /// Creates a [TreeView].
  const TreeView({
    super.key,
    required this.itemBuilder,
    required this.controller,
    this.transitionBuilder = defaultTreeViewTransitionBuilder,
    this.maxNodesToShowWhenAnimating = 50,
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
  }) : assert(maxNodesToShowWhenAnimating > 0);

  /// The controller responsible for managing the expansion state and animations
  /// of the tree provided by its [TreeController.tree].
  final TreeController<T> controller;

  /// Callback used to map your data into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds.
  final TreeViewItemBuilder<T> itemBuilder;

  /// Callback used to animate the expansion state change of a subtree.
  ///
  /// See also:
  ///
  /// * [defaultTreeViewTransitionBuilder] that uses a [SizeTransition].
  final TreeViewTransitionBuilder transitionBuilder;

  /// The amount of nodes that are going to be shown on an animating subtree.
  ///
  /// Must be a value greater than `0`, since the "pseudo root" of the animating
  /// subtree should always be visible.
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
  final int maxNodesToShowWhenAnimating;

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

  /// The amount of space by which to inset the tree contents.
  ///
  /// It defaults to `EdgeInsets.zero`.
  final EdgeInsetsGeometry? padding;

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
            itemBuilder: itemBuilder,
            transitionBuilder: transitionBuilder,
            maxNodesToShowWhenAnimating: maxNodesToShowWhenAnimating,
          ),
        ),
      ],
    );
  }
}
