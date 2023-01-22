import 'dart:async' show Timer;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/widgets.dart';

import 'sliver_tree.dart';

/// A widget that wraps either [Draggable] or [LongPressDraggable] depending on
/// the value provided to [longPressDelay] providing additional capabilities.
/// It is also responsible for automatically collapsing the node it holds
/// when the drag starts and expanding it back when the drag ends (if it was
/// collapsed). This can be toggled off in [collapseOnDragStart].
///
/// This widget is also responsible for calling [SliverTreeState.onNodeDragStarted]
/// which creates a set with [node] and all the ancestors nodes to make sure it
/// is not removed from the widget tree in the middle of the drag gesture.
/// When hovering a [TreeDragTarget], the drag target will check if
/// [SliverTreeState.draggingNodePath] contains the hovering node so it
/// doesn't start the auto toggle expansion timer. When the drag gesture ends,
/// [SliverTreeState.onNodeDragEnded] is called to clear the
/// [SliverTreeState.draggingNodePath] set.
///
/// Depends on an ancestor [SliverTree] to work.
class TreeDraggable<T extends Object> extends StatefulWidget {
  /// Creates a [TreeDraggable].
  ///
  /// This widget wraps a [LongPressDraggable] by default, to change it to a
  /// [Draggable], provide a [longPressDelay] of [Duration.zero].
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
    this.longPressDelay = kLongPressTimeout,
    this.longPressHapticFeedbackOnStart = true,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.affinity,
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

  /// Whether [node] should be collapsed when the drag gesture starts.
  ///
  /// This requires that a [TreeController] is provided to [TreeView] or
  /// [SliverTree].
  final bool collapseOnDragStart;

  /// Whether [node] should be expanded when the drag gesture ends.
  ///
  /// This requires that a [TreeController] is provided to [TreeView] or
  /// [SliverTree].
  final bool expandOnDragEnd;

  /// Defines the size of the [Rect] created around the drag global position
  /// when dragging a tree node.
  ///
  /// The [Rect] is used to detect when the user drags too close to the vertical
  /// edges of the scrollable viewport to start auto scrolling if necessary.
  ///
  /// If [autoScrollSensitivity] is set to `100.0`, the detected area
  /// will be `50.0` pixels in each direction centered on the drag global position.
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
  ///  * [childDragAnchorStrategy], which displays the feedback anchored at the
  ///    position of the original child.
  ///
  ///  * [pointerDragAnchorStrategy], which displays the feedback anchored at the
  ///    position of the touch that started the drag.
  ///
  /// Defaults to [pointerDragAnchorStrategy].
  final DragAnchorStrategy? dragAnchorStrategy;

  /// Whether haptic feedback should be triggered on drag start when using a
  /// [LongPressDraggable] (i.e. `longPressDelay != Duration.zero`).
  final bool longPressHapticFeedbackOnStart;

  /// The [Duration] that the user has to press down before a long press is
  /// registered.
  ///
  /// Defaults to [kLongPressTimeout].
  final Duration longPressDelay;

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

  @override
  State<TreeDraggable<T>> createState() => _TreeDraggableState<T>();
}

class _TreeDraggableState<T extends Object> extends State<TreeDraggable<T>>
    with AutomaticKeepAliveClientMixin {
  T get node => widget.node;

  late SliverTreeState<T> _treeState;

  bool get isExpanded => _treeState.getExpansionState(node);

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

  void _autoScroll(Offset offset) {
    _treeState.startAutoScrollIfNecessary(
      Rect.fromCenter(
        center: offset,
        width: widget.autoScrollSensitivity,
        height: widget.autoScrollSensitivity,
      ),
    );
  }

  void _endDrag() {
    _isDragging = false;

    _treeState
      ..stopAutoScroll()
      ..onNodeDragEnded();

    if (widget.expandOnDragEnd && !isExpanded) {
      _treeState.toggleExpansion(node, animate: false);
    }
  }

  void onDragStarted() {
    _isDragging = true;

    _treeState.onNodeDragStarted(node);

    if (widget.collapseOnDragStart && isExpanded) {
      _treeState.toggleExpansion(node, animate: false);
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
    _treeState = SliverTree.of<T>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.longPressDelay == Duration.zero) {
      return Draggable<T>(
        data: node,
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
        child: widget.child,
      );
    }

    return LongPressDraggable<T>(
      data: node,
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
      delay: widget.longPressDelay,
      hapticFeedbackOnStart: widget.longPressHapticFeedbackOnStart,
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
/// Contains the exact position where the drop ocurred [dropPosition] as well as
/// the bounding box [targetBounds] of the target widget providing versatility
/// to what happens when reordering nodes on a tree.
class TreeReorderingDetails<T extends Object> with Diagnosticable {
  /// Creates a [TreeReorderingDetails].
  const TreeReorderingDetails({
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

  /// The exact position inside [targetBounds] that [draggedNode] was dropped.
  final Offset dropPosition;

  /// The widget bounding box of [targetNode] that received the [draggedNode].
  final Rect targetBounds;

  /// Contains the list of drag data that is hovering over the [TreeDragTarget]
  /// and that has passed [TreeDragTarget.onWillAccept].
  final List<T?> candidateData;

  /// Contains the list of drag data that is hovering over this [TreeDragTarget]
  /// and that will not be accepted by the [TreeDragTarget].
  final List<dynamic> rejectedData;

  /// Used by [TreeDragTarget] to update the data that is hovering itself before
  /// providing this details to [TreeDragTarget.builder].
  TreeReorderingDetails<T> applyData(
    List<T?> candidateData,
    List<dynamic> rejectedData,
  ) {
    return TreeReorderingDetails<T>(
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
  TreeReorderingDetails<T>? details,
);

/// Signature for a function that takes a [TreeReorderingDetails] instance.
/// Used by [TreeDragTarget] to complete a reordering action.
typedef TreeOnReorderCallback<T extends Object> = void Function(
  TreeReorderingDetails<T> details,
);

/// A widget that wraps [DragTarget] providing auto expansion toggling
/// capabilities.
///
/// Depends on an ancestor [SliverTree] to work.
class TreeDragTarget<T extends Object> extends StatefulWidget {
  /// Creates a [TreeDragTarget].
  const TreeDragTarget({
    super.key,
    required this.node,
    required this.builder,
    required this.onReorder,
    this.toggleExpansionTimeout = const Duration(seconds: 1),
    this.canStartToggleExpansionTimer = true,
    this.onWillAccept,
    this.onAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    this.hitTestBehavior = HitTestBehavior.translucent,
  });

  /// The tree node that is going to receive the drop of a [TreeDraggable].
  final T node;

  /// The callback that is going to be called when a dragging node was
  /// successfully dropped onto this drag target. It should then apply the
  /// reordering to the tree view nodes and call [TreeController.rebuild]
  /// to show the newly reordered tree data.
  final TreeOnReorderCallback<T> onReorder;

  /// Called to build the contents of this widget.
  ///
  /// The builder can build different widgets depending on what is being dragged
  /// into this drag target.
  ///
  /// If the details is `null`, there's currently no draggable widget hovering
  /// this drag target.
  final TreeDraggableBuilder<T> builder;

  /// The default time to wait before toggling the expansion of [node] when it
  /// is being hovered by another node.
  ///
  /// This requires that a [TreeController] is provided to [TreeView] or
  /// [SliverTree].
  ///
  /// To disable auto expansion toggle, provide a duration of [Duration.zero].
  ///
  /// Defaults to `const Duration(seconds: 1)`.
  final Duration toggleExpansionTimeout;

  /// A flag used to decide if the toggle expansion timer should start when this
  /// node is being hovered by another dragging node.
  ///
  /// Defaults to `true`.
  final bool canStartToggleExpansionTimer;

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
  T get node => widget.node;

  late SliverTreeState<T> _treeState;

  Timer? _toggleExpansionTimer;

  void startToggleExpansionTimer() {
    stopToggleExpansionTimer();

    if (widget.canStartToggleExpansionTimer && _canToggle) {
      _toggleExpansionTimer = Timer(
        widget.toggleExpansionTimeout,
        () => _treeState.toggleExpansion(node),
      );
    }
  }

  void stopToggleExpansionTimer() {
    _toggleExpansionTimer?.cancel();
    _toggleExpansionTimer = null;
  }

  late bool _isToggleExpansionEnabled;

  bool get _isInDraggedNodePath {
    return _treeState.draggingNodePath.contains(node);
  }

  // Only toggle the expansion of a node if it is not in the path to the target
  // node, if an ancestor of the dragged node is collapsed, its dragging state
  // is lost.
  bool get _canToggle => _isToggleExpansionEnabled && !_isInDraggedNodePath;

  void _updateIsToggleExpansionEnabled() {
    _isToggleExpansionEnabled = widget.toggleExpansionTimeout != Duration.zero;
  }

  TreeReorderingDetails<T>? _details;

  TreeReorderingDetails<T> _getDropDetails(T incomingNode, Offset pointer) {
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;

    return TreeReorderingDetails<T>(
      draggedNode: incomingNode,
      targetNode: node,
      dropPosition: renderBox.globalToLocal(pointer),
      targetBounds: Offset.zero & renderBox.size,
    );
  }

  bool onWillAccept(T? data) {
    if (widget.onWillAccept != null) {
      return widget.onWillAccept!(data);
    }
    return !(data == null || data == node);
  }

  void onMove(DragTargetDetails<T> details) {
    // Do not allow dropping a node on itself.
    if (details.data == node) return;

    // If the incoming data is not the same as the cached data, reject it.
    // This makes sure we only handle one draggable at a time.
    if (_details != null && details.data != _details!.draggedNode) return;

    stopToggleExpansionTimer();

    setState(() {
      _details = _getDropDetails(details.data, details.offset);
    });

    startToggleExpansionTimer();
    widget.onMove?.call(details);
  }

  void onAccept(T incomingNode) {
    stopToggleExpansionTimer();

    if (_details == null || _details!.draggedNode != incomingNode) return;

    widget.onReorder(_details!);

    setState(() {
      _details = null;
    });

    widget.onAccept?.call(incomingNode);
  }

  void onLeave(T? data) {
    if (_details == null || data == null || _details!.draggedNode != data) {
      return;
    }

    stopToggleExpansionTimer();

    setState(() {
      _details = null;
    });

    widget.onLeave?.call(data);
  }

  @override
  void initState() {
    super.initState();
    _updateIsToggleExpansionEnabled();
  }

  @override
  void didUpdateWidget(covariant TreeDragTarget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateIsToggleExpansionEnabled();

    if (oldWidget.canStartToggleExpansionTimer !=
        widget.canStartToggleExpansionTimer) {
      stopToggleExpansionTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _treeState = SliverTree.of<T>(context);
  }

  @override
  void dispose() {
    stopToggleExpansionTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAccept: onWillAccept,
      onAccept: onAccept,
      onAcceptWithDetails: widget.onAcceptWithDetails,
      onLeave: onLeave,
      onMove: onMove,
      hitTestBehavior: widget.hitTestBehavior,
      builder: (
        BuildContext context,
        List<T?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return widget.builder(
          context,
          _details?.applyData(candidateData, rejectedData),
        );
      },
    );
  }
}
