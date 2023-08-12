import 'dart:async' show Timer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'sliver_tree.dart';
import 'tree_controller.dart';

/// A widget that wraps either [Draggable] or [LongPressDraggable] depending on
/// the value of [longPressDelay], with additional tree view capabilities.
///
/// It is also responsible for automatically collapsing the node it holds
/// when the drag starts and expanding it back when the drag ends (if it was
/// collapsed). This can be toggled off in [collapseOnDragStart].
///
/// Usage:
/// ```dart
/// Widget build(BuildContext context) {
///   return TreeDraggable<Node>(
///     node: entry.node,
///     // Usually the child wrapped in [Material] widget (and [IntrinsicWidth] if necessary).
///     feedback: MyTreeNodeTileFeedback(),
///     // Usually the child widget with some opacity.
///     childWhenDragging: MyTreeNodeTileWhenDragging(),
///     child: MyTreeNodeTile(),
///   );
/// }
/// ```
///
/// This widget depends on an ancestor [TreeViewScope], which is automatically
/// added to the widget tree by [SliverTree] and [SliverAnimatedTree].
class TreeDraggable<T extends Object> extends StatefulWidget {
  /// Creates a [TreeDraggable].
  ///
  /// By default, this widget creates a [Draggable] widget, to change it to a
  /// [LongPressDraggable], provide a [longPressDelay] different than `null`.
  const TreeDraggable({
    super.key,
    required this.child,
    required this.node,
    this.collapseOnDragStart = true,
    this.expandOnDragEnd = false,
    this.autoScrollSensitivity = 100.0,
    this.axis,
    required this.feedback,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = pointerDragAnchorStrategy,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.affinity,
    this.ignoringFeedbackSemantics = true,
    this.ignoringFeedbackPointer = true,
    this.rootOverlay = false,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.longPressDelay,
    this.longPressHapticFeedbackOnStart = true,
  });

  /// The widget below this widget in the tree.
  ///
  /// This widget displays [child] when not dragging. If [childWhenDragging] is
  /// non-null, this widget instead displays [childWhenDragging] when dragging.
  /// Otherwise, this widget always displays [child].
  ///
  /// The [feedback] widget is shown under the pointer when dragging.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The tree node that is going to be provided to [Draggable.data].
  final T node;

  /// Whether [node] should be collapsed when the inner [Draggable] detects the
  /// start of a drag gesture.
  ///
  /// Defaults to `true`.
  final bool collapseOnDragStart;

  /// Whether [node] should be expanded when the inner [Draggable] detects the
  /// end of a drag gesture.
  ///
  /// Defaults to `false`.
  final bool expandOnDragEnd;

  /// Defines the size of the [Rect] created around the drag global position
  /// when dragging a tree node.
  ///
  /// The [Rect] is used to detect when the user drags too close to the edges
  /// of the scrollable viewport to start auto scrolling if necessary.
  ///
  /// If [autoScrollSensitivity] is set to `100.0`, the detected area will be
  /// `50.0` pixels in each direction centered on the drag global position.
  ///
  /// Defaults to `100.0`.
  final double autoScrollSensitivity;

  /// The [Axis] to restrict this draggable's movement, if specified.
  ///
  /// When axis is set to [Axis.horizontal], this widget can only be dragged
  /// horizontally. Behavior is similar for [Axis.vertical].
  ///
  /// Defaults to allowing drag on both [Axis.horizontal] and [Axis.vertical].
  ///
  /// When null, allows drag on both [Axis.horizontal] and [Axis.vertical].
  ///
  /// For the direction of gestures this widget competes with to start a drag
  /// event, see [Draggable.affinity].
  final Axis? axis;

  /// The widget to show under the pointer when a drag is under way.
  ///
  /// See [child] and [childWhenDragging] for information about what is shown
  /// at the location of the [Draggable] itself when a drag is under way.
  final Widget feedback;

  /// The widget to display instead of [child] when one or more drags are under
  /// way.
  ///
  /// If this is null, then this widget will always display [child] (and so the
  /// drag source representation will not change while a drag is under way).
  ///
  /// The [feedback] widget is shown under the pointer when a drag is under way.
  final Widget? childWhenDragging;

  /// The feedbackOffset can be used to set the hit test target point for the
  /// purposes of finding a drag target. It is especially useful if the feedback
  /// is transformed compared to the child.
  final Offset feedbackOffset;

  /// A strategy that is used by this draggable to get the anchor offset when it
  /// is dragged.
  ///
  /// The anchor offset refers to the distance between the users' fingers and
  /// the [feedback] widget when this draggable is dragged.
  ///
  /// This property's value is a function that implements [DragAnchorStrategy].
  /// There are two built-in functions that can be used:
  ///
  /// * [childDragAnchorStrategy], which displays the feedback anchored at the
  ///   position of the original child.
  ///
  /// * [pointerDragAnchorStrategy], which displays the feedback anchored at the
  ///   position of the touch that started the drag.
  ///
  /// Defaults to [pointerDragAnchorStrategy].
  final DragAnchorStrategy dragAnchorStrategy;

  /// Whether the semantics of the [feedback] widget is ignored when building
  /// the semantics tree.
  ///
  /// This value should be set to false when the [feedback] widget is intended
  /// to be the same object as the [child]. Placing a [GlobalKey] on this
  /// widget will ensure semantic focus is kept on the element as it moves in
  /// and out of the feedback position.
  ///
  /// Defaults to true.
  final bool ignoringFeedbackSemantics;

  /// Whether the [feedback] widget is ignored during hit testing.
  ///
  /// Regardless of whether this widget is ignored during hit testing, it will
  /// still consume space during layout and be visible during painting.
  ///
  /// Defaults to true.
  final bool ignoringFeedbackPointer;

  /// Called when the draggable starts being dragged.
  final VoidCallback? onDragStarted;

  /// Called when the draggable is dragged.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true), and if this widget has actually moved.
  final DragUpdateCallback? onDragUpdate;

  /// Called when the draggable is dropped without being accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up being canceled, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final DraggableCanceledCallback? onDraggableCanceled;

  /// Called when the draggable is dropped and accepted by a [DragTarget].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up completing, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final VoidCallback? onDragCompleted;

  /// Called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTarget] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final DragEndCallback? onDragEnd;

  /// Controls how this widget competes with other gestures to initiate a drag.
  ///
  /// If affinity is null, this widget initiates a drag as soon as it recognizes
  /// a tap down gesture, regardless of any directionality. If affinity is
  /// horizontal (or vertical), then this widget will compete with other
  /// horizontal (or vertical, respectively) gestures.
  ///
  /// For example, if this widget is placed in a vertically scrolling region and
  /// has horizontal affinity, pointer motion in the vertical direction will
  /// result in a scroll and pointer motion in the horizontal direction will
  /// result in a drag. Conversely, if the widget has a null or vertical
  /// affinity, pointer motion in any direction will result in a drag rather
  /// than in a scroll because the draggable widget, being the more specific
  /// widget, will out-compete the [Scrollable] for vertical gestures.
  ///
  /// For the directions this widget can be dragged in after the drag event
  /// starts, see [Draggable.axis].
  final Axis? affinity;

  /// Whether the feedback widget will be put on the root [Overlay].
  ///
  /// When false, the feedback widget will be put on the closest [Overlay]. When
  /// true, the [feedback] widget will be put on the farthest (aka root)
  /// [Overlay].
  ///
  /// Defaults to false.
  final bool rootOverlay;

  /// How to behave during hit test.
  ///
  /// Defaults to [HitTestBehavior.deferToChild].
  final HitTestBehavior hitTestBehavior;

  /// Whether haptic feedback should be triggered on drag start when using a
  /// [LongPressDraggable] (i.e., `longPressDelay != null`).
  final bool longPressHapticFeedbackOnStart;

  /// The [Duration] that the user has to press down before a long press is
  /// registered.
  ///
  /// This property also decides which of [Draggable] or [LongPressDraggable] is
  /// created by this widget. A null [Duration] will use a standard [Draggable]
  /// widget, any other value will result in a [LongPressDraggable] being used.
  ///
  /// Defaults to `null`.
  final Duration? longPressDelay;

  @override
  State<TreeDraggable<T>> createState() => _TreeDraggableState<T>();
}

class _TreeDraggableState<T extends Object> extends State<TreeDraggable<T>>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => _isDragging;

  bool get _isDragging => _dragging;
  bool _dragging = false;
  set _isDragging(bool value) {
    if (value == _dragging) return;

    if (mounted) {
      setState(() {
        _dragging = value;
        updateKeepAlive();
      });
    } else {
      _dragging = value;
    }
  }

  TreeViewScope<T>? _treeScope;
  TreeController<T> get treeController {
    assert(_treeScope != null);
    return _treeScope!.controller;
  }

  EdgeDraggingAutoScroller? _autoScroller;
  Offset? _dragPointer;

  void _createAutoScroller([ScrollableState? scrollable]) {
    _autoScroller = EdgeDraggingAutoScroller(
      scrollable ?? Scrollable.of(context),
      velocityScalar: 20,
      onScrollViewScrolled: () {
        if (_dragPointer != null) {
          _autoScroll(_dragPointer!);
        }
      },
    );
  }

  void _autoScroll(Offset offset) {
    _dragPointer = offset;
    _autoScroller?.startAutoScrollIfNecessary(
      Rect.fromCenter(
        center: offset,
        width: widget.autoScrollSensitivity,
        height: widget.autoScrollSensitivity,
      ),
    );
  }

  void _stopAutoScroll() {
    _dragPointer = null;
    _autoScroller?.stopAutoScroll();
  }

  void _endDrag() {
    _isDragging = false;
    _stopAutoScroll();

    if (widget.expandOnDragEnd) {
      treeController.expand(widget.node);
    }
  }

  void onDragStarted() {
    _isDragging = true;
    _createAutoScroller();

    if (widget.collapseOnDragStart) {
      treeController.collapse(widget.node);
    }
    widget.onDragStarted?.call();
  }

  void onDragUpdate(DragUpdateDetails details) {
    _autoScroll(details.globalPosition);
    widget.onDragUpdate?.call(details);
  }

  void onDraggableCanceled(Velocity velocity, Offset offset) {
    _endDrag();
    widget.onDraggableCanceled?.call(velocity, offset);
  }

  void onDragCompleted() {
    _endDrag();
    widget.onDragCompleted?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _treeScope = TreeViewScope.of<T>(context);

    late final ScrollableState scrollable = Scrollable.of(context);
    if (_autoScroller != null && _autoScroller!.scrollable != scrollable) {
      _createAutoScroller(scrollable);
    }
  }

  @override
  void dispose() {
    _isDragging = false;
    _stopAutoScroll();
    _autoScroller = null;
    _treeScope = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.longPressDelay != null) {
      return LongPressDraggable<T>(
        data: widget.node,
        maxSimultaneousDrags: 1,
        onDragStarted: onDragStarted,
        onDragUpdate: onDragUpdate,
        onDraggableCanceled: onDraggableCanceled,
        onDragEnd: widget.onDragEnd,
        onDragCompleted: onDragCompleted,
        feedback: widget.feedback,
        axis: widget.axis,
        childWhenDragging: widget.childWhenDragging,
        feedbackOffset: widget.feedbackOffset,
        dragAnchorStrategy: widget.dragAnchorStrategy,
        ignoringFeedbackPointer: widget.ignoringFeedbackPointer,
        ignoringFeedbackSemantics: widget.ignoringFeedbackPointer,
        delay: widget.longPressDelay!,
        hapticFeedbackOnStart: widget.longPressHapticFeedbackOnStart,
        child: widget.child,
      );
    }

    return Draggable<T>(
      data: widget.node,
      maxSimultaneousDrags: 1,
      onDragStarted: onDragStarted,
      onDragUpdate: onDragUpdate,
      onDraggableCanceled: onDraggableCanceled,
      onDragEnd: widget.onDragEnd,
      onDragCompleted: onDragCompleted,
      feedback: widget.feedback,
      axis: widget.axis,
      childWhenDragging: widget.childWhenDragging,
      feedbackOffset: widget.feedbackOffset,
      dragAnchorStrategy: widget.dragAnchorStrategy,
      ignoringFeedbackPointer: widget.ignoringFeedbackPointer,
      ignoringFeedbackSemantics: widget.ignoringFeedbackPointer,
      affinity: widget.affinity,
      rootOverlay: widget.rootOverlay,
      hitTestBehavior: widget.hitTestBehavior,
      child: widget.child,
    );
  }
}

/// The details of the drag-and-drop relationship of [TreeDraggable] and
/// [TreeDragTarget].
///
/// Details are created and updated when a node [draggedNode] is hovering
/// another node [targetNode].
///
/// Contains the exact position where the drop ocurred [dropPosition] as well
/// as the bounding box [targetBounds] of the target widget which enables many
/// different ways for a node to adopt another node depending on where it was
/// dropped.
///
/// The following example splits the height of [targetBounds] in three and
/// decides where to drop [draggedNode] depending on the `dy` property of
/// [dropPosition]:
///
/// ```dart
/// extension on TreeDragAndDropDetails<Object> {
///   T mapDropPosition<T>({
///     required T Function() whenAbove,
///     required T Function() whenInside,
///     required T Function() whenBelow,
///   }) {
///     final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
///     final double pointerVerticalOffset = dropPosition.dy;
///
///     if (pointerVerticalOffset < oneThirdOfTotalHeight) {
///        return whenAbove();
///     } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
///       return whenInside();
///     } else {
///       return whenBelow();
///     }
///   }
/// }
/// ```
/// > The above example is used by the drag and drop sample code in the
/// > examples directory (example/lib/src/examples/drag_and_drop.dart).
class TreeDragAndDropDetails<T extends Object> with Diagnosticable {
  /// Creates a [TreeDragAndDropDetails].
  const TreeDragAndDropDetails({
    required this.draggedNode,
    required this.targetNode,
    required this.dropPosition,
    required this.targetBounds,
    this.candidateData = const [],
    this.rejectedData = const [],
  });

  /// The node that was dragged around and dropped on [targetNode].
  final T draggedNode;

  /// The node that received the drop of [draggedNode].
  final T targetNode;

  /// The exact hovering position of [draggedNode] inside [targetBounds].
  ///
  /// This can be used to decide what will happen to [draggedNode] once it is
  /// dropped at this vicinity of [targetBounds], whether it will become a
  /// child of [targetNode], a sibling, its parent, etc.
  final Offset dropPosition;

  /// The widget bounding box of [targetNode].
  ///
  /// This combined with [dropPosition] can be used to allow the user to drop
  /// the dragging node at different parts of the target node which could lead
  /// to different behaviors, e.g. drop as: previous sibling, first child, last
  /// child, next sibling, parent, etc.
  final Rect targetBounds;

  /// Contains the list of drag data that is hovering over the [TreeDragTarget]
  /// that was passed to [TreeDragTarget.onWillAccept].
  ///
  /// This and [rejectedData] are collected from the data given to the builder
  /// callback of the [DragTarget] widget.
  final List<T?> candidateData;

  /// Contains the list of drag data that is hovering over this [TreeDragTarget]
  /// that will not be accepted by the [TreeDragTarget].
  ///
  /// This and [candidateData] are collected from the data given to the builder
  /// callback of the [DragTarget] widget.
  final List<dynamic> rejectedData;

  TreeDragAndDropDetails<T> _applyData(
    List<T?> candidateData,
    List<dynamic> rejectedData,
  ) {
    return TreeDragAndDropDetails<T>(
      draggedNode: draggedNode,
      targetNode: targetNode,
      dropPosition: dropPosition,
      targetBounds: targetBounds,
      candidateData: candidateData,
      rejectedData: rejectedData,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('draggedNode', draggedNode))
      ..add(DiagnosticsProperty<T>('targetNode', targetNode))
      ..add(DiagnosticsProperty<Offset>('dropPosition', dropPosition))
      ..add(DiagnosticsProperty<Rect>('targetBounds', targetBounds));
  }
}

/// Signature for a function used by [TreeDragTarget] to build a widget based
/// on the provided [details].
typedef TreeDraggableBuilder<T extends Object> = Widget Function(
  BuildContext context,
  TreeDragAndDropDetails<T>? details,
);

/// Signature for a function that takes a [TreeDragAndDropDetails] instance.
/// Used by [TreeDragTarget] to complete a drop action.
typedef TreeDragTargetNodeAccepted<T extends Object> = void Function(
  TreeDragAndDropDetails<T> details,
);

/// A [DragTarget] wrapper that provides some additional tree view capabilities
/// like auto toggle expansion on hover.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return TreeDragTarget<Node>(
///     // The node that will receive the drop from dragging nodes.
///     node: entry.node,
///
///     // The following callback is used to apply the changes to the tree
///     // structure when the dragging node is accepted by this target node.
///     onNodeAccepted: (TreeDragAndDropDetails<Node> details) { },
///
///     // If details is provided, there's a [TreeDraggable] currently hovering
///     // this drag target, add some decoration to the tree node tile to show
///     // to the user what will happen when they drop the node in this target.
///     builder: (BuildContext context, TreeDragAndDropDetails<Node>? details) {
///       if (details != null) {
///         return MyDecoratedTreeNodeTile();
///       }
///       return MyTreeNodeTile();
///     },
///   ),
/// }
/// ```
class TreeDragTarget<T extends Object> extends StatefulWidget {
  /// Creates a [TreeDragTarget].
  const TreeDragTarget({
    super.key,
    required this.node,
    required this.builder,
    required this.onNodeAccepted,
    this.toggleExpansionOnHover = true,
    this.toggleExpansionDelay = const Duration(seconds: 1),
    this.canToggleExpansion = true,
    this.onWillAccept,
    this.onAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    this.hitTestBehavior = HitTestBehavior.translucent,
  });

  /// The tree node that is going to receive the drop of a [TreeDraggable].
  final T node;

  /// Called when a dragging node was successfully dropped onto this drag
  /// target.
  ///
  /// This callback is responsible for applying the reorder operation to the
  /// tree structure and call [TreeController.rebuild] to show the newly
  /// reordered tree data.
  final TreeDragTargetNodeAccepted<T> onNodeAccepted;

  /// Called to build the contents of this widget.
  ///
  /// The builder can build different widgets depending on what is being dragged
  /// into this drag target.
  ///
  /// If the [details] provided to this byilder is not `null`, there's currently
  /// a draggable widget hovering this drag target.
  final TreeDraggableBuilder<T> builder;

  /// Whether to automatically toggle the expansion state of [node] when it is
  /// being hovered by another dragging tree node.
  ///
  /// The [toggleExpansionDelay] can be used to control the [Duration] to wait
  /// before calling [TreeController.toggleExpansion] with the target node.
  ///
  /// Defaults to `true`.
  final bool toggleExpansionOnHover;

  /// The [Duration] to wait before automatically toggling the expansion state
  /// of [node] when it is being hovered by another dragging tree node.
  ///
  /// Defaults to `Duration(seconds: 1)`.
  final Duration toggleExpansionDelay;

  /// Whether [node] can have its expansion state toggled when it is being
  /// hovered by another dragging tree node.
  ///
  /// This is checked after [toggleExpansionDelay] has ellapsed but right before
  /// [TreeController.toggleExpansion] is called, making it possible to halt
  /// the toggle operation while the timer is running, without stopping it.
  ///
  /// Defaults to `true`.
  final bool canToggleExpansion;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final DragTargetWillAccept<T>? onWillAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAcceptWithDetails], but only includes the data.
  final DragTargetAccept<T>? onAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAccept], but with information, including the data, in a
  /// [DragTargetDetails].
  final DragTargetAcceptWithDetails<T>? onAcceptWithDetails;

  /// Called when a given piece of data being dragged over this target leaves
  /// the target.
  final DragTargetLeave<T>? onLeave;

  /// Called when a [Draggable] moves within this [DragTarget].
  ///
  /// Note that this includes entering and leaving the target.
  final DragTargetMove<T>? onMove;

  /// How to behave during hit testing.
  ///
  /// Defaults to [HitTestBehavior.translucent].
  final HitTestBehavior hitTestBehavior;

  @override
  State<TreeDragTarget<T>> createState() => _TreeDragTargetState<T>();
}

class _TreeDragTargetState<T extends Object> extends State<TreeDragTarget<T>> {
  TreeViewScope<T>? _treeScope;
  TreeController<T> get treeController => _treeScope!.controller;

  Timer? _toggleExpansionTimer;

  void _cancelToggleExpansionTimer() {
    _toggleExpansionTimer?.cancel();
    _toggleExpansionTimer = null;
  }

  void _startToggleExpansionTimer(T incomingNode) {
    if (!widget.toggleExpansionOnHover) {
      return;
    }

    final bool targetIsAncestor = treeController.checkNodeHasAncestor(
      node: incomingNode,
      potentialAncestor: widget.node,
      checkForEquality: true,
    );

    // Disallow toggling the expansion state if the target node is an ancestor
    // of the dragging node as if an ancestor is collapsed, the dragging node
    // would be removed from the view, stopping the drag geture.
    if (targetIsAncestor) {
      return;
    }

    _toggleExpansionTimer?.cancel();
    _toggleExpansionTimer = Timer(widget.toggleExpansionDelay, () {
      if (widget.canToggleExpansion) {
        treeController.toggleExpansion(widget.node);
      }
    });
  }

  TreeDragAndDropDetails<T>? _details;

  TreeDragAndDropDetails<T> _getDropDetails(T incomingNode, Offset pointer) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;

    return TreeDragAndDropDetails<T>(
      draggedNode: incomingNode,
      targetNode: widget.node,
      dropPosition: renderBox.globalToLocal(pointer),
      targetBounds: Offset.zero & renderBox.size,
    );
  }

  bool _onWillAccept(T? data) {
    if (widget.onWillAccept != null) {
      return widget.onWillAccept!(data);
    }
    return !(data == null || data == widget.node);
  }

  void _onMove(DragTargetDetails<T> details) {
    _cancelToggleExpansionTimer();

    // Do not allow dropping a node on itself.
    if (details.data == widget.node) return;

    // If the incoming data is not the same as the cached data, reject it.
    // This makes sure we only handle one draggable at a time.
    if (_details != null && details.data != _details!.draggedNode) return;

    setState(() {
      _details = _getDropDetails(details.data, details.offset);
    });

    _startToggleExpansionTimer(details.data);
    widget.onMove?.call(details);
  }

  void _onAccept(T incomingNode) {
    _cancelToggleExpansionTimer();

    if (_details == null || _details!.draggedNode != incomingNode) return;

    widget.onAccept?.call(incomingNode);
    widget.onNodeAccepted(_details!);

    setState(() {
      _details = null;
    });
  }

  void _onLeave(T? data) {
    if (_details == null || data == null || _details!.draggedNode != data) {
      return;
    }

    _cancelToggleExpansionTimer();

    setState(() {
      _details = null;
    });

    widget.onLeave?.call(data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _treeScope = TreeViewScope.of<T>(context);
  }

  @override
  void dispose() {
    _treeScope = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAccept: _onWillAccept,
      onAccept: _onAccept,
      onAcceptWithDetails: widget.onAcceptWithDetails,
      onLeave: _onLeave,
      onMove: _onMove,
      hitTestBehavior: widget.hitTestBehavior,
      builder: (
        BuildContext context,
        List<T?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return widget.builder(
          context,
          _details?._applyData(candidateData, rejectedData),
        );
      },
    );
  }
}
