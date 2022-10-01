import 'package:flutter/material.dart';

import '../foundation.dart';
import 'tree_indentation.dart';

/// A simple widget to be used in a [Treeview].
///
/// The [indentGuide] can be used to configure line painting and define the
/// indent used when calculating the indentation of this item. If not provided,
/// uses the default values of a constant [ConnectingLinesGuide].
///
/// The [child] is usually composed of a [Row] with 2 widgets, the label of the
/// node and a button to toggle its expansion state.
///
/// Examples:
///
/// ```dart
/// final TreeController<T> treeController;
/// final TreeEntry<T> entry;
///
/// TreeItem<T>(
///   child: Row(
///     children: [
///       const Expanded(
///         child: Text('My node Title'),
///       ),
///       ExpandIcon(
///         isExpanded: entry.isExpanded,
///         onPressed: (_) => treeController.toggleExpansion(entry.node),
///       ),
///     ],
///   ),
/// );
///
/// ```
/// Or whithout a button, using `onTap`:
///
/// ```dart
/// final TreeController<T> treeController;
/// final TreeEntry<T> entry;
///
/// TreeItem<T>(
///   onTap: (_) => treeController.toggleExpansion(entry.node),
///   child: const Text('My node Title'),
/// );
/// ```
///
/// See also:
///   * [FolderButton], a button that when tapped toggles between open and
///     closed folder icons, useful for expanding/collapsing a [TreeItem];
class TreeItem<T extends Object> extends StatelessWidget {
  /// Creates a [TreeItem].
  const TreeItem({
    super.key,
    required this.child,
    required this.treeEntry,
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

  /// The tree entry of this tree item.
  ///
  /// The tree entry is used by [TreeIndentation] to correctly apply the
  /// indentation of tree items (and paint lines, if enabled).
  final TreeEntry<T> treeEntry;

  /// The configuration used to indent and paint lines (if enabled).
  ///
  /// If not provided, [ConnectingLinesGuide] will be used with its default
  /// constructor values.
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

  @override
  Widget build(BuildContext context) {
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
      child: TreeIndentation<T>(
        treeEntry: treeEntry,
        guide: indentGuide,
        child: child,
      ),
    );
  }
}
