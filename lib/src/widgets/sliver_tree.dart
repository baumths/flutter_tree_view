import 'dart:collection' show UnmodifiableSetView;
import 'dart:math' as math show min;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../foundation.dart';
import 'tree_indentation.dart' show TreeIndentDetailsScope;

/// Signature for a function that creates a widget for a given entry, e.g., in a
/// tree.
typedef TreeViewItemBuilder<T extends TreeNode<T>> = Widget Function(
  BuildContext context,
  TreeEntry<T> entry,
);

/// Signature for a function that takes a widget and an animation to apply
/// transitions if needed.
typedef TreeViewTransitionBuilder = Widget Function(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

/// The default transition builder used by [SliverTree] to animate the expansion
/// state changes of a node.
///
/// Wraps [child] in [SizeTransition].
Widget defaultTreeViewTransitionBuilder(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  return SizeTransition(
    sizeFactor: animation,
    child: child,
  );
}

/// A widget that wraps a [SliverList] adding tree viewing capabilities.
class SliverTree<T extends TreeNode<T>> extends StatefulWidget {
  /// Creates a [SliverTree].
  const SliverTree({
    super.key,
    required this.itemBuilder,
    required this.controller,
    this.transitionBuilder = defaultTreeViewTransitionBuilder,
    this.maxNodesToShowWhenAnimating = 50,
  });

  /// The controller responsible for managing the expansion state and animations
  /// of the tree provided by its [TreeController.tree].
  final TreeController<T> controller;

  /// Callback used to map your data into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds.
  final TreeViewItemBuilder<T> itemBuilder;

  /// Callback used to animate the expansion state changes of a subtree.
  ///
  /// See also:
  ///
  ///   * [defaultTreeViewTransitionBuilder] that uses a [SizeTransition].
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

  /// The [SliverTree] from the closest instance of this class that encloses the
  /// given context.
  ///
  /// If there is no [SliverTree] ancestor in the widget tree at the given
  /// context, then this will return null.
  ///
  /// Typical usage is as follows:
  ///
  /// SliverTreeState<T>? treeState = SliverTree.maybeOf<T>(context);
  ///
  /// See also:
  ///
  ///  * [of], which will throw in debug mode if no [SliverTree] ancestor exists
  ///    in the widget tree.
  static SliverTreeState<T>? maybeOf<T extends TreeNode<T>>(
    BuildContext context,
  ) {
    return context.findAncestorStateOfType<SliverTreeState<T>>();
  }

  /// The [SliverTree] from the closest instance of this class that encloses the
  /// given context.
  ///
  /// If there is no [SliverTree] ancestor in the widget tree at the given
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
  ///  * [maybeOf], which will return null if no [SliverTree] ancestor exists in
  ///    the widget tree.
  static SliverTreeState<T> of<T extends TreeNode<T>>(BuildContext context) {
    final SliverTreeState<T>? instance = maybeOf<T>(context);
    assert(() {
      if (instance == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverTree.of() called with a context that does not contain a '
            'SliverTree.',
          ),
          ErrorDescription(
            'No SliverTree ancestor could be found starting from the context '
            'that was passed to SliverTree.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same '
            'StatefulWidget that built the SliverTree.',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return instance!;
  }

  @override
  State<SliverTree<T>> createState() => SliverTreeState<T>();
}

/// The object that holds the state of a [SliverTree].
class SliverTreeState<T extends TreeNode<T>> extends State<SliverTree<T>> {
  /// The controller responsible for managing the expansion state and animations
  /// of the tree provided by its [TreeController.tree].
  TreeController<T> get controller => widget.controller;

  void _rebuild() => setState(() {});

  //* REORDERING ---------------------------------------------------------------

  Rect _autoScrollRect = Rect.zero;
  VerticalEdgeDraggingAutoScroller? _autoScroller;

  void _handleScrollableAutoScrolled() {
    if (_autoScrollRect == Rect.zero) return;
    // Continue scrolling if the drag is still in progress.
    _autoScroller?.startAutoScrollIfNecessary(_autoScrollRect);
  }

  /// Starts scrolling the ancestor [Scrollable] if [rect] is close enough to
  /// the vertical edges of the scrollable's viewport.
  ///
  /// Used by [TreeDraggable] to auto scroll when dragging.
  void startAutoScrollIfNecessary(Rect rect) {
    _autoScrollRect = rect;
    _autoScroller?.startAutoScrollIfNecessary(_autoScrollRect);
  }

  /// Stops scrolling the ancestor [Scrollable].
  ///
  /// Used by [TreeDraggable] when stopped dragging.
  void stopAutoScroll() {
    _autoScroller?.stopAutoScroll();
    _autoScrollRect = Rect.zero;
  }

  /// An unordered set of node ids composed by the ids of every ancestor of the
  /// node that is currently being dragged (if any).
  /// If no node is currenlty being dragged, returns an empty set.
  ///
  /// Used by [TreeDragTarget] to avoid collapsing the ancestors of a dragging
  /// node.
  UnmodifiableSetView<Object> get draggingNodePath => _draggingNodePath;
  UnmodifiableSetView<Object> _draggingNodePath = UnmodifiableSetView(const {});

  /// Called by [TreeDraggable] when it starts dragging to make sure that the
  /// dragged node stays visible during the drag gesture by disabling auto
  /// toggle expansion.
  ///
  /// This should not be used from outside of [TreeDraggable].
  void onNodeDragStarted(T node) {
    final TreeEntry<T>? entry = controller.getCurrentEntryOfNode(node);
    if (entry == null) return;

    final Set<Object> path = {node.id};

    TreeEntry<T>? current = entry.parent;
    while (current != null) {
      path.add(current.node.id);
      current = current.parent;
    }

    _draggingNodePath = UnmodifiableSetView<Object>(path);
  }

  /// Called by [TreeDraggable] when it stops dragging to clear [draggingNodePath].
  ///
  /// This should not be used from outside of [TreeDraggable].
  void onNodeDragEnded() {
    _draggingNodePath = UnmodifiableSetView(const {});
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(_rebuild);

    if (controller.flattenedTree.isEmpty) {
      controller.rebuild();
    }
  }

  @override
  void didUpdateWidget(covariant SliverTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_rebuild);
      controller.addListener(_rebuild);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ScrollableState scrollable = Scrollable.of(context)!;

    if (_autoScroller?.scrollable != scrollable) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = VerticalEdgeDraggingAutoScroller(
        scrollable: scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
      );
    }
  }

  @override
  void dispose() {
    controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        _itemBuilder,
        childCount: controller.flattenedTree.length,
      ),
    );
  }

  Widget _keyedItemBuilder(BuildContext context, TreeEntry<T> entry) {
    return TreeIndentDetailsScope(
      key: _SaltedKey(entry.node.id),
      details: entry,
      child: Builder(
        builder: (BuildContext context) => widget.itemBuilder(context, entry),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final TreeEntry<T> entry = controller.entryAt(index);

    final AnimatableTreeCommand<T>? command =
        controller.getAnimatableCommand(entry.node);

    if (command == null) {
      return _keyedItemBuilder(context, entry);
    }

    return _AnimatingSubTree<T>(
      itemBuilder: _keyedItemBuilder,
      transitionBuilder: widget.transitionBuilder,
      maxNodesToShowWhenAnimating: widget.maxNodesToShowWhenAnimating,
      root: entry.node,
      rootDetails: entry,
      command: command,
      onAnimationComplete: () {
        controller.onAnimatableCommandComplete(entry.node);
      },
    );
  }
}

class _SaltedKey<T extends State<StatefulWidget>> extends GlobalObjectKey<T> {
  const _SaltedKey(super.value);
}

class _AnimatingSubTree<T extends TreeNode<T>> extends StatefulWidget {
  const _AnimatingSubTree({
    super.key,
    required this.root,
    required this.rootDetails,
    required this.command,
    required this.itemBuilder,
    required this.transitionBuilder,
    required this.maxNodesToShowWhenAnimating,
    required this.onAnimationComplete,
  });

  final T root;
  final TreeIndentDetails rootDetails;
  final AnimatableTreeCommand<T> command;
  final VoidCallback onAnimationComplete;
  final TreeViewItemBuilder<T> itemBuilder;
  final TreeViewTransitionBuilder transitionBuilder;
  final int maxNodesToShowWhenAnimating;

  @override
  State<_AnimatingSubTree<T>> createState() => _AnimatingSubTreeState<T>();
}

class _AnimatingSubTreeState<T extends TreeNode<T>>
    extends State<_AnimatingSubTree<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;

  T get root => widget.root;
  AnimatableTreeCommand<T> get command => widget.command;

  late List<TreeEntry<T>> _branch;
  late TreeEntry<T> _rootEntry;
  late int _itemCount;

  void _maybeAutoScroll() {
    final RenderObject? renderObject = context.findRenderObject();
    RenderAbstractViewport.of(renderObject)?.showOnScreen(
      descendant: renderObject,
    );
  }

  void onAnimationComplete() {
    widget.onAnimationComplete();
  }

  @override
  void initState() {
    super.initState();
    _branch = buildFlatTree<T>(
      roots: [root],
      startingLevel: widget.rootDetails.level,
    );
    // at least the "pseudo root" must be present
    assert(_branch.isNotEmpty);
    _rootEntry = _branch.first;

    // Make sure to add the lines of the ancestors in the main tree, so that
    // this subtree doesn't appear floating "contextless" in the line hierarchy.
    //
    // Adding the extra line levels to the root will ensure all descendants have
    // it due to the recursive [TreeEntry.ancestorLevelsWithVerticalLines] calls.
    _rootEntry.addVerticalLinesAtLevels(
      widget.rootDetails.ancestorLevelsWithVerticalLines,
    );

    _itemCount = math.min(_branch.length, widget.maxNodesToShowWhenAnimating);

    _controller = AnimationController(vsync: this, duration: command.duration);
    _animation = CurvedAnimation(parent: _controller, curve: command.curve);

    if (command.tryAutoScrolling) {
      _controller.addListener(_maybeAutoScroll);
    }
    command.animate(_controller).whenCompleteOrCancel(onAnimationComplete);
  }

  @override
  void didUpdateWidget(covariant _AnimatingSubTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = command.duration;
    _animation.curve = command.curve;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_itemCount == 1) {
      return widget.itemBuilder(context, _rootEntry);
    }

    late final Widget descendants = IgnorePointer(
      ignoring: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int index = 1; index < _itemCount; index++)
            widget.itemBuilder(context, _branch[index]),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.itemBuilder(context, _rootEntry),
        widget.transitionBuilder(context, descendants, _animation),
      ],
    );
  }
}
