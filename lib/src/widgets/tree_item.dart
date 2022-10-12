import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';

import '../foundation.dart';
import 'drag_and_drop.dart';
import 'tree_indentation.dart';

/// Examples can assume:
/// ```dart
/// class MyNode extends TreeNode<MyNode> {}
///
/// final TreeController<MyNode> treeController;
/// final MyNode node;
/// ```

/// A simple widget to be used in a [Treeview].
///
/// The [indentGuide] can be used to configure line painting and define the
/// indent used when calculating the indentation of this item. If not provided,
/// defaults to [DefaultIndentGuide.of], which if not found, creates a constant
/// [ConnectingLinesGuide].
///
/// The [child] is usually composed of a [Row] with 2 widgets, the label of the
/// node and a button to toggle its expansion state.
///
/// Examples:
///
/// ```dart
/// TreeItem(
///   child: Row(
///     children: [
///       const Expanded(
///         child: Text('My node Title'),
///       ),
///       ExpandIcon(
///         isExpanded: node.isExpanded,
///         onPressed: (_) => treeController.toggleExpansion(node),
///       ),
///     ],
///   ),
/// );
///
/// ```
/// Or whithout a button, using `onTap`:
///
/// ```dart
/// TreeItem(
///   onTap: () => treeController.toggleExpansion(node),
///   child: const Text('My node Title'),
/// );
/// ```
///
/// See also:
///   * [FolderButton], a button that when tapped toggles between open and
///     closed folder icons, useful for expanding/collapsing a [TreeItem];
class TreeItem extends StatelessWidget {
  /// Creates a [TreeItem].
  const TreeItem({
    super.key,
    required this.child,
    this.indentGuide,
    this.onTap,
    this.onTapUp,
    this.onTapDown,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.onFocusChange,
    this.canRequestFocus = true,
    this.focusNode,
    this.autofocus = false,
    this.statesController,
  });

  /// The widget to display to the side of [TreeIndentation].
  final Widget child;

  /// The configuration used by [TreeIndentation] to indent this item and paint
  /// lines (if enabled).
  ///
  /// If not provided, [DefaultIndentGuide.of] will be used.
  ///
  /// Check out the factory constructors of [IndentGuide] to discover the
  /// available indent guide decorations.
  final IndentGuide? indentGuide;

  /// Called when the user taps this part of the material.
  final GestureTapCallback? onTap;

  /// Called when the user releases a tap that was started on this part of the
  /// material. [onTap] is called immediately after.
  final GestureTapUpCallback? onTapUp;

  /// Called when the user taps down this part of the material.
  final GestureTapDownCallback? onTapDown;

  /// Called when the user cancels a tap that was started on this part of the
  /// material.
  final GestureTapCallback? onTapCancel;

  /// Called when the user double taps this part of the material.
  final GestureTapCallback? onDoubleTap;

  /// Called when the user long-presses on this part of the material.
  final GestureLongPressCallback? onLongPress;

  /// Called when this part of the material either becomes highlighted or stops
  /// being highlighted.
  ///
  /// The value passed to the callback is true if this part of the material has
  /// become highlighted and false if this part of the material has stopped
  /// being highlighted.
  ///
  /// If all of [onTap], [onDoubleTap], and [onLongPress] become null while a
  /// gesture is ongoing, then [onTapCancel] will be fired and
  /// [onHighlightChanged] will be fired with the value false _during the
  /// build_. This means, for instance, that in that scenario [State.setState]
  /// cannot be called.
  final ValueChanged<bool>? onHighlightChanged;

  /// Called when a pointer enters or exits the ink response area.
  ///
  /// The value passed to the callback is true if a pointer has entered this
  /// part of the material and false if a pointer has exited this part of the
  /// material.
  final ValueChanged<bool>? onHover;

  /// The cursor for a mouse pointer when it enters or is hovering over the
  /// widget.
  ///
  /// If [mouseCursor] is a [MaterialStateProperty<MouseCursor>],
  /// [MaterialStateProperty.resolve] is used for the following [MaterialState]s:
  ///
  ///  * [MaterialState.hovered].
  ///  * [MaterialState.focused].
  ///  * [MaterialState.disabled].
  ///
  /// If this property is null, [MaterialStateMouseCursor.clickable] will be used.
  final MouseCursor? mouseCursor;

  /// The radius of the ink splash.
  ///
  /// Splashes grow up to this size. By default, this size is determined from
  /// the size of the rectangle provided by [getRectCallback], or the size of
  /// the [InkResponse] itself.
  ///
  /// See also:
  ///
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final double? radius;

  /// The clipping radius of the containing rect. This is effective only if
  /// [customBorder] is null.
  ///
  /// If this is null, it is interpreted as [BorderRadius.zero].
  final BorderRadius? borderRadius;

  /// The custom clip border which overrides [borderRadius].
  final ShapeBorder? customBorder;

  /// The color of the ink response when the parent widget is focused. If this
  /// property is null then the focus color of the theme,
  /// [ThemeData.focusColor], will be used.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [hoverColor], the color of the hover highlight.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color? focusColor;

  /// The color of the ink response when a pointer is hovering over it. If this
  /// property is null then the hover color of the theme,
  /// [ThemeData.hoverColor], will be used.
  ///
  /// See also:
  ///
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [highlightColor], the color of the pressed highlight.
  ///  * [focusColor], the color of the focus highlight.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color? hoverColor;

  /// The highlight color of the ink response when pressed. If this property is
  /// null then the highlight color of the theme, [ThemeData.highlightColor],
  /// will be used.
  ///
  /// See also:
  ///
  ///  * [hoverColor], the color of the hover highlight.
  ///  * [focusColor], the color of the focus highlight.
  ///  * [highlightShape], the shape of the focus, hover, and pressed
  ///    highlights.
  ///  * [splashColor], the color of the splash.
  ///  * [splashFactory], which defines the appearance of the splash.
  final Color? highlightColor;

  /// Defines the ink response focus, hover, and splash colors.
  ///
  /// This default null property can be used as an alternative to
  /// [focusColor], [hoverColor], [highlightColor], and
  /// [splashColor]. If non-null, it is resolved against one of
  /// [MaterialState.focused], [MaterialState.hovered], and
  /// [MaterialState.pressed]. It's convenient to use when the parent
  /// widget can pass along its own MaterialStateProperty value for
  /// the overlay color.
  ///
  /// [MaterialState.pressed] triggers a ripple (an ink splash), per
  /// the current Material Design spec. The [overlayColor] doesn't map
  /// a state to [highlightColor] because a separate highlight is not
  /// used by the current design guidelines.  See
  /// https://material.io/design/interaction/states.html#pressed
  ///
  /// If the overlay color is null or resolves to null, then [focusColor],
  /// [hoverColor], [splashColor] and their defaults are used instead.
  ///
  /// See also:
  ///
  ///  * The Material Design specification for overlay colors and how they
  ///    match a component's state:
  ///    <https://material.io/design/interaction/states.html#anatomy>.
  final MaterialStateProperty<Color?>? overlayColor;

  /// The splash color of the ink response. If this property is null then the
  /// splash color of the theme, [ThemeData.splashColor], will be used.
  ///
  /// See also:
  ///
  ///  * [splashFactory], which defines the appearance of the splash.
  ///  * [radius], the (maximum) size of the ink splash.
  ///  * [highlightColor], the color of the highlight.
  final Color? splashColor;

  /// Defines the appearance of the splash.
  ///
  /// Defaults to the value of the theme's splash factory: [ThemeData.splashFactory].
  ///
  /// See also:
  ///
  ///  * [radius], the (maximum) size of the ink splash.
  ///  * [splashColor], the color of the splash.
  ///  * [highlightColor], the color of the highlight.
  ///  * [InkSplash.splashFactory], which defines the default splash.
  ///  * [InkRipple.splashFactory], which defines a splash that spreads out
  ///    more aggressively than the default.
  final InteractiveInkFeatureFactory? splashFactory;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  /// Whether to exclude the gestures introduced by this widget from the
  /// semantics tree.
  ///
  /// For example, a long-press gesture for showing a tooltip is usually
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.canRequestFocus}
  final bool canRequestFocus;

  /// {@macro flutter.material.inkwell.statesController}
  final MaterialStatesController? statesController;

  Widget _wrap(Widget content) {
    return InkWell(
      onTap: onTap,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      onTapCancel: onTapCancel,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onHighlightChanged: onHighlightChanged,
      onHover: onHover,
      mouseCursor: mouseCursor,
      radius: radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      overlayColor: overlayColor,
      splashColor: splashColor,
      splashFactory: splashFactory,
      enableFeedback: enableFeedback,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      statesController: statesController,
      child: TreeIndentation(
        guide: indentGuide,
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _wrap(child);
}

/// Signature for a function used by [ReorderableTreeItem] to decorate its child
/// widget from the provided [TreeReorderingDetails].
typedef TreeReorderDecorationBuilder<T extends TreeNode<T>> = Widget Function(
  BuildContext context,
  Widget child,
  TreeReorderingDetails<T> details,
);

/// A [TreeItem] wrapped in [TreeDraggable] and [TreeDragTarget], providing
/// reordering capabilities.
class ReorderableTreeItem<T extends TreeNode<T>> extends TreeItem {
  /// Creates a [ReorderableTreeItem].
  const ReorderableTreeItem({
    super.key,
    required super.child,
    required this.node,
    super.indentGuide,
    super.onTap,
    super.onTapUp,
    super.onTapDown,
    super.onTapCancel,
    super.onDoubleTap,
    super.onLongPress,
    super.onHighlightChanged,
    super.onHover,
    super.mouseCursor,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.overlayColor,
    super.splashColor,
    super.splashFactory,
    super.radius,
    super.borderRadius,
    super.customBorder,
    super.enableFeedback,
    super.excludeFromSemantics,
    super.focusNode,
    super.canRequestFocus,
    super.onFocusChange,
    super.autofocus,
    super.statesController,
    this.collapseOnDragStart = true,
    this.autoScrollSensitivity = 100.0,
    this.toggleExpansionTimeout = const Duration(seconds: 1),
    this.canStartToggleExpansionTimer,
    required this.onReorder,
    this.decorationBuilder,
    this.decorationWrapsChildOnly = true,
    required this.feedback,
    this.axis,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = pointerDragAnchorStrategy,
    this.requireLongPress = false,
    this.longPressHapticFeedbackOnStart = true,
    this.longPressTimeout = kLongPressTimeout,
    this.affinity,
  });

  /// The [TreeNode] that will both receive other dragging nodes on the
  /// [TreeDragTarget] and also be dragged around by [TreeDraggable].
  final T node;

  /// Whether [node] should be collapsed when the drag gesture starts.
  ///
  /// Defaults to `true`.
  final bool collapseOnDragStart;

  /// Defines the size of the [Rect] created around the drag global position
  /// when dragging a tree item.
  ///
  /// The [Rect] is used to detect when the user drags too close to the vertical
  /// edges of the scrollable viewport to start auto scrolling if necessary.
  ///
  /// If [autoScrollSensitivity] is set to `100.0`, the detected area will be
  /// `50.0` pixels in each direction centered on the drag global position.
  ///
  /// Defaults to `100.0`.
  final double autoScrollSensitivity;

  /// The default delay to wait before toggling the expansion of [node] when it
  /// is being hovered by another node.
  ///
  /// To disable auto expansion toggle, provide a duration of [Duration.zero].
  ///
  /// Defaults to `const Duration(seconds: 1)`.
  final Duration toggleExpansionTimeout;

  /// A simple callback used to decide if the [TreeDragTarget]'s toggle expansion
  /// timer should start when this node is being hovered by another dragging node.
  ///
  /// If this callback is `null`, the timer always starts.
  final ValueGetter<bool>? canStartToggleExpansionTimer;

  /// The callback that will handle the actual reordering of nodes.
  ///
  /// Called when a successful drop ocurred on this widget.
  ///
  /// Opinionated examples:
  /// > The following functions could be abstracted and used as both [onReorder]
  /// > and [decorationBuilder] to provide visual feedback of what would happen
  /// > when dropping the dragged node onto this node. Check out
  /// > "example/lib/src/reordering.dart" that uses the last function of below.
  ///
  /// ```dart
  /// void onReorder<T extends TreeNode<T>>(TreeReorderingDetails<T> details) {
  ///   // [details.draggedNode] dropped onto [details.targetNode], add the
  ///   // dragged node to the children of the target node.
  /// }
  ///
  /// void onReorder<T extends TreeNode<T>>(TreeReorderingDetails<T> details) {
  ///   final double y = details.dropPosition.dy;
  ///   final double heightFactor = details.targetBounds.height / 2;
  ///
  ///   if (y <= heightFactor) {
  ///     // [details.draggedNode] dropped on the top half,
  ///     // could reorder as previous sibling of [details.targetNode].
  ///   } else {
  ///     // [details.draggedNode] dropped on the bottom half,
  ///     // could reorder as child or next sibling of [details.targetNode].
  ///   }
  /// }
  ///
  /// void onReorder<T extends TreeNode<T>>(TreeReorderingDetails<T> details) {
  ///   final double y = details.dropPosition.dy;
  ///   final double heightFactor = details.targetBounds.height / 3;
  ///
  ///   if (y <= heightFactor) {
  ///     // [details.draggedNode] dropped on the top third,
  ///     // could reorder as previous sibling to [details.targetNode].
  ///   } else if (y <= heightFactor * 2) {
  ///     // [details.draggedNode] dropped on the center third,
  ///     // could reorder as (first/last) child of [details.targetNode].
  ///   } else {
  ///     // [details.draggedNode] dropped on the bottom third,
  ///     // could reorder as next sibling or first child of [details.targetNode].
  ///   }
  /// }
  /// ```
  final TreeOnReorderCallback<T> onReorder;

  /// Widget builder used to apply decorations when this node is hovered by
  /// another node.
  ///
  /// This builder is used to add an optional decoration to [child] when this
  /// tree item is being hovered by another dragging tree item. This can be used
  /// to show a feedback to the user of what will happen to a node when it is
  /// dropped and accepted by this node.
  ///
  /// Example:
  /// ```dart
  /// Widget decorationBuilder<T extends TreeNode<T>>(
  ///   BuildContext context,
  ///   Widget child,
  ///   TreeReorderingDetails<T> details,
  /// ) {
  ///   const BorderSide borderSide = BorderSide();
  ///   final double y = details.dropPosition.dy;
  ///   final double heightFactor = details.targetBounds.height / 3;
  ///
  ///   late final Border border;
  ///
  ///   if (y <= heightFactor) {
  ///     border = const Border(top: borderSide);
  ///   } else if (y <= heightFactor * 2) {
  ///     border = const Border.fromBorderSide(borderSide);
  ///   } else {
  ///     border = const Border(bottom: borderSide);
  ///   }
  ///
  ///   return DecoratedBox(
  ///     decoration: BoxDecoration(border: border),
  ///     child: child,
  ///   );
  /// }
  /// ```
  final TreeReorderDecorationBuilder<T>? decorationBuilder;

  /// If `true`, the [decorationBuilder] will only wrap [child]. If `false`,
  /// wraps the entire underlying [InkWell] + [TreeIndentation].
  ///
  /// Defaults to `true`.
  final bool decorationWrapsChildOnly;

  /// The widget to show under the pointer when a drag is under way.
  ///
  /// See [child] and [childWhenDragging] for information about what is shown
  /// at the location of the [Draggable] itself when a drag is under way.
  final Widget feedback;

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

  /// If set to `true` will always use a long press gesture, not depending on
  /// the current platform.
  ///
  /// Defaults to `false`.
  final bool requireLongPress;

  /// Whether haptic feedback should be triggered on drag start when
  /// [requireLongPress] is set to `true` or [defaultTargetPlatform] resolves to
  /// [DelayedMultiDragGestureRecognizer].
  final bool longPressHapticFeedbackOnStart;

  /// The duration that the user has to press down before a long press is
  /// registered.
  ///
  /// Defaults to [kLongPressTimeout].
  final Duration longPressTimeout;

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
  Widget build(BuildContext context) {
    return TreeDraggable<T>(
      node: node,
      collapseOnDragStart: collapseOnDragStart,
      autoScrollSensitivity: autoScrollSensitivity,
      feedback: feedback,
      axis: axis,
      childWhenDragging: childWhenDragging,
      feedbackOffset: feedbackOffset,
      dragAnchorStrategy: dragAnchorStrategy,
      requireLongPress: requireLongPress,
      longPressHapticFeedbackOnStart: longPressHapticFeedbackOnStart,
      longPressTimeout: longPressTimeout,
      affinity: affinity,
      child: TreeDragTarget<T>(
        node: node,
        onReorder: onReorder,
        canStartToggleExpansionTimer: canStartToggleExpansionTimer,
        toggleExpansionTimeout: toggleExpansionTimeout,
        builder: (BuildContext context, TreeReorderingDetails<T>? details) {
          if (details == null || decorationBuilder == null) {
            return _wrap(child);
          }

          if (decorationWrapsChildOnly) {
            return _wrap(decorationBuilder!(context, child, details));
          }

          return decorationBuilder!(context, _wrap(child), details);
        },
      ),
    );
  }
}
