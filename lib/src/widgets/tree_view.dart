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
class TreeView<T extends TreeNode<T>> extends StatefulWidget {
  /// Creates a [TreeView].
  const TreeView({
    super.key,
    required this.roots,
    required this.itemBuilder,
    this.transitionBuilder = defaultTreeViewTransitionBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.linear,
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

  /// The root [TreeNode]s of the tree.
  ///
  /// These nodes are used as a starting point to build the flat representation
  /// of the tree.
  final Iterable<T> roots;

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

  /// The default duration to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Duration(milliseconds: 300)`.
  final Duration animationDuration;

  /// The default curve to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Curves.linear`.
  final Curve animationCurve;

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

  /// The [TreeView] from the closest instance of this class that encloses the
  /// given context.
  ///
  /// If there is no [TreeView] ancestor in the widget tree at the given
  /// context, then this will return null.
  ///
  /// Typical usage is as follows:
  ///
  /// SliverTreeState<T>? treeState = SliverTree.maybeOf<T>(context);
  ///
  /// See also:
  ///
  ///  * [of], which will throw in debug mode if no [TreeView] ancestor exists
  ///    in the widget tree.
  static TreeViewState<T>? maybeOf<T extends TreeNode<T>>(
    BuildContext context,
  ) {
    return context.findAncestorStateOfType<TreeViewState<T>>();
  }

  /// The [TreeView] from the closest instance of this class that encloses the
  /// given context.
  ///
  /// If there is no [TreeView] ancestor in the widget tree at the given
  /// context, then this will throw in debug mode.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SliverTreeState<T> treeState = SliverTree.of<T>(context);
  /// ```
  ///
  /// See also:
  ///
  ///  * [maybeOf], which will return null if no [TreeView] ancestor exists in
  ///    the widget tree.
  static TreeViewState<T> of<T extends TreeNode<T>>(BuildContext context) {
    final TreeViewState<T>? instance = maybeOf<T>(context);
    assert(() {
      if (instance == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'TreeView.of() called with a context that does not contain a '
            'TreeView.',
          ),
          ErrorDescription(
            'No TreeView ancestor could be found starting from the context '
            'that was passed to TreeView.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same '
            'StatefulWidget that built the TreeView.',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return instance!;
  }

  @override
  State<TreeView<T>> createState() => TreeViewState<T>();
}

/// The state of a [TreeView].
///
/// Can be used to rebuild the flattened tree of the descendant [SliverTree].
///
/// See also:
/// * [TreeViewState.rebuild], which delegates its call to
///   [SliverTreeState.rebuild].
/// * [TreeViewState.toggleExpansion], which delegates its call to
///   [SliverTreeState.toggleExpansion].
class TreeViewState<T extends TreeNode<T>> extends State<TreeView<T>> {
  final GlobalKey<SliverTreeState<T>> _sliverTreeKey = GlobalKey();

  /// This method delegates its call to [SliverTreeState.rebuild].
  ///
  /// {@macro flutter_fancy_tree_view.SliverTreeState.rebuild}
  void rebuild({bool animate = true}) {
    _sliverTreeKey.currentState!.rebuild(animate: animate);
  }

  /// This method delegates its call to [SliverTreeState.toggleExpansion].
  ///
  /// {@macro flutter_fancy_tree_view.SliverTreeState.toggleExpansion}
  void toggleExpansion(T node, {bool animate = true}) {
    _sliverTreeKey.currentState!.toggleExpansion(node, animate: animate);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollDirection: Axis.vertical,
      reverse: false,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      scrollBehavior: widget.scrollBehavior,
      shrinkWrap: widget.shrinkWrap,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: [
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverTree<T>(
            key: _sliverTreeKey,
            roots: widget.roots,
            itemBuilder: widget.itemBuilder,
            transitionBuilder: widget.transitionBuilder,
            animationDuration: widget.animationDuration,
            animationCurve: widget.animationCurve,
            maxNodesToShowWhenAnimating: widget.maxNodesToShowWhenAnimating,
          ),
        ),
      ],
    );
  }
}
