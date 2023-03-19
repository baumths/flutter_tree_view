import 'package:flutter/material.dart';

/// The default transition builder used by [FolderButton].
///
/// Wraps [child] in a [ScaleTransition].
Widget defaultFolderButtonTransitionBuilder(
  Widget child,
  Animation<double> animation,
) {
  return ScaleTransition(scale: animation, child: child);
}

/// A wrapper around [IconButton] and [AnimatedSwitcher] that animates between
/// [icon], [openedIcon] and [closedIcon] depending on the value of [isOpen].
///
/// The value of [isOpen] is mapped as follows:
/// `null`  -> [icon]       -> [Icons.article]
/// `true`  -> [openedIcon] -> [Icons.folder_open]
/// `false` -> [closedIcon] -> [Icons.folder]
///
/// Example:
/// ```dart
/// final TreeEntry entry;
/// final TreeController controller;
///
/// @override
/// Widget build(BuildContext context) {
///   bool? isOpen;
///   VoidCallback? onPressed;
///
///   if (entry.hasChildren) {
///     isOpen = entry.isExpanded;
///     onPressed = () => controller.toggleExpansion(entry.node);
///   }
///
///   return FolderButton(
///     isOpen: isOpen,
///     onPressed: onPressed,
///   );
/// }
/// ```
///
/// In the above example, the [isOpen] property is composed depending on the
/// context of a [TreeEntry]. This widget will show [icon] when the entry is a
/// leaf (i.e., has no children), [openedIcon] when the expansion state is set
/// to `true` and [closedIcon] if the expansion state is set to `false`. The
/// [onPressed] callback is set to `null` when the entry is a leaf disabling
/// the button.
class FolderButton extends StatelessWidget {
  /// Creates a [FolderButton].
  const FolderButton({
    super.key,
    this.isOpen = true,
    this.icon = const Icon(Icons.article),
    this.openedIcon = const Icon(Icons.folder_open),
    this.closedIcon = const Icon(Icons.folder),
    this.iconSize,
    this.visualDensity,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    this.splashRadius,
    this.focusColor,
    this.hoverColor,
    this.color,
    this.splashColor,
    this.highlightColor,
    this.disabledColor,
    this.onPressed,
    this.mouseCursor,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.enableFeedback = true,
    this.constraints,
    this.style,
    this.duration = kThemeAnimationDuration,
    this.curve = Curves.linear,
    this.transitionBuilder = defaultFolderButtonTransitionBuilder,
  });

  /// Defines which of [icon], [openedIcon] and [closedIcon] is currently shown.
  final bool? isOpen;

  /// The icon to show when [isOpen] is set to `null`.
  ///
  /// Defaults to `Icon(Icons.article)`.
  final Widget icon;

  /// The icon to show when [isOpen] is set to `true`.
  ///
  /// Defaults to `Icon(Icons.folder_open)`.
  final Widget openedIcon;

  /// The icon to show when [isOpen] is set to `false`.
  ///
  /// Defaults to `Icon(Icons.folder)`.
  final Widget closedIcon;

  /// The size of the icon inside the button.
  ///
  /// If null, uses [IconThemeData.size]. If it is also null, the default size
  /// is 24.0.
  ///
  /// The size given here is passed down to the widget in the [icon] property
  /// via an [IconTheme]. Setting the size here instead of in, for example, the
  /// [Icon.size] property allows the [IconButton] to size the splash area to
  /// fit the [Icon]. If you were to set the size of the [Icon] using
  /// [Icon.size] instead, then the [IconButton] would default to 24.0 and then
  /// the [Icon] itself would likely get clipped.
  final double? iconSize;

  /// Defines how compact the icon button's layout will be.
  ///
  /// {@macro flutter.material.themedata.visualDensity}
  ///
  /// See also:
  ///
  ///  * [ThemeData.visualDensity], which specifies the [visualDensity] for all
  ///    widgets within a [Theme].
  final VisualDensity? visualDensity;

  /// The padding around the button's icon. The entire padded icon will react
  /// to input gestures.
  ///
  /// This property must not be null. It defaults to 8.0 padding on all sides.
  final EdgeInsetsGeometry padding;

  /// Defines how the icon is positioned within the IconButton.
  ///
  /// This property must not be null. It defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// The splash radius.
  ///
  /// If [ThemeData.useMaterial3] is set to true, this will not be used.
  ///
  /// If null, default splash radius of [Material.defaultSplashRadius] is used.
  final double? splashRadius;

  /// The color for the button when it has the input focus.
  ///
  /// If [ThemeData.useMaterial3] is set to true, this [focusColor] will be mapped
  /// to be the [ButtonStyle.overlayColor] in focused state, which paints on top of
  /// the button, as an overlay. Therefore, using a color with some transparency
  /// is recommended. For example, one could customize the [focusColor] below:
  ///
  /// ```dart
  /// IconButton(
  ///   focusColor: Colors.orange.withOpacity(0.3),
  /// )
  /// ```
  ///
  /// Defaults to [ThemeData.focusColor] of the ambient theme.
  final Color? focusColor;

  /// The color for the button when a pointer is hovering over it.
  ///
  /// If [ThemeData.useMaterial3] is set to true, this [hoverColor] will be mapped
  /// to be the [ButtonStyle.overlayColor] in hovered state, which paints on top of
  /// the button, as an overlay. Therefore, using a color with some transparency
  /// is recommended. For example, one could customize the [hoverColor] below:
  ///
  /// ```dart
  /// IconButton(
  ///   hoverColor: Colors.orange.withOpacity(0.3),
  /// )
  /// ```
  ///
  /// Defaults to [ThemeData.hoverColor] of the ambient theme.
  final Color? hoverColor;

  /// The color to use for the icon inside the button, if the icon is enabled.
  /// Defaults to leaving this up to the [icon] widget.
  ///
  /// The icon is enabled if [onPressed] is not null.
  ///
  /// ```dart
  /// IconButton(
  ///   color: Colors.blue,
  ///   onPressed: _handleTap,
  ///   icon: Icons.widgets,
  /// )
  /// ```
  final Color? color;

  /// The primary color of the button when the button is in the down (pressed) state.
  /// The splash is represented as a circular overlay that appears above the
  /// [highlightColor] overlay. The splash overlay has a center point that matches
  /// the hit point of the user touch event. The splash overlay will expand to
  /// fill the button area if the touch is held for long enough time. If the splash
  /// color has transparency then the highlight and button color will show through.
  ///
  /// If [ThemeData.useMaterial3] is set to true, this will not be used. Use
  /// [highlightColor] instead to show the overlay color of the button when the button
  /// is in the pressed state.
  ///
  /// Defaults to the Theme's splash color, [ThemeData.splashColor].
  final Color? splashColor;

  /// The secondary color of the button when the button is in the down (pressed)
  /// state. The highlight color is represented as a solid color that is overlaid over the
  /// button color (if any). If the highlight color has transparency, the button color
  /// will show through. The highlight fades in quickly as the button is held down.
  ///
  /// If [ThemeData.useMaterial3] is set to true, this [highlightColor] will be mapped
  /// to be the [ButtonStyle.overlayColor] in pressed state, which paints on top
  /// of the button, as an overlay. Therefore, using a color with some transparency
  /// is recommended. For example, one could customize the [highlightColor] below:
  ///
  /// ```dart
  /// IconButton(
  ///   highlightColor: Colors.orange.withOpacity(0.3),
  /// )
  /// ```
  ///
  /// Defaults to the Theme's highlight color, [ThemeData.highlightColor].
  final Color? highlightColor;

  /// The color to use for the icon inside the button, if the icon is disabled.
  /// Defaults to the [ThemeData.disabledColor] of the current [Theme].
  ///
  /// The icon is disabled if [onPressed] is null.
  final Color? disabledColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback? onPressed;

  /// {@macro flutter.material.RawMaterialButton.mouseCursor}
  ///
  /// If set to null, will default to
  /// - [SystemMouseCursors.basic], if [onPressed] is null
  /// - [SystemMouseCursors.click], otherwise
  final MouseCursor? mouseCursor;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String? tooltip;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool enableFeedback;

  /// Optional size constraints for the button.
  ///
  /// When unspecified, defaults to:
  /// ```dart
  /// const BoxConstraints(
  ///   minWidth: kMinInteractiveDimension,
  ///   minHeight: kMinInteractiveDimension,
  /// )
  /// ```
  /// where [kMinInteractiveDimension] is 48.0, and then with visual density
  /// applied.
  ///
  /// The default constraints ensure that the button is accessible.
  /// Specifying this parameter enables creation of buttons smaller than
  /// the minimum size, but it is not recommended.
  ///
  /// The visual density uses the [visualDensity] parameter if specified,
  /// and `Theme.of(context).visualDensity` otherwise.
  final BoxConstraints? constraints;

  /// Customizes this button's appearance.
  ///
  /// Non-null properties of this style override the corresponding
  /// properties in [_IconButtonM3.themeStyleOf] and [_IconButtonM3.defaultStyleOf].
  /// [MaterialStateProperty]s that resolve to non-null values will similarly
  /// override the corresponding [MaterialStateProperty]s in [_IconButtonM3.themeStyleOf]
  /// and [_IconButtonM3.defaultStyleOf].
  ///
  /// The [style] is only used for Material 3 [IconButton]. If [ThemeData.useMaterial3]
  /// is set to true, [style] is preferred for icon button customization, and any
  /// parameters defined in [style] will override the same parameters in [IconButton].
  ///
  /// For example, if [IconButton]'s [visualDensity] is set to [VisualDensity.standard]
  /// and [style]'s [visualDensity] is set to [VisualDensity.compact],
  /// the icon button will have [VisualDensity.compact] to define the button's layout.
  ///
  /// Null by default.
  final ButtonStyle? style;

  /// The duration of the transition of the icons.
  ///
  /// Defaults to [kThemeAnimationDuration].
  final Duration duration;

  /// The animation curve to use when transitioning the icons.
  ///
  /// Defaults to [Curves.linear]
  final Curve curve;

  /// The transition funciton used to animate the icons swap.
  ///
  /// Default to wrapping the icon in a [ScaleTransition].
  ///
  /// See also:
  ///
  ///  * [AnimatedSwitcherTransitionBuilder] for more information about
  ///    how a transition builder should function.
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  Widget get _effectiveIcon {
    switch (isOpen) {
      case true:
        return openedIcon;
      case false:
        return closedIcon;
      case null:
      default:
        return icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: iconSize,
      visualDensity: visualDensity,
      padding: padding,
      alignment: alignment,
      splashRadius: splashRadius,
      focusColor: focusColor,
      hoverColor: hoverColor,
      color: color,
      splashColor: splashColor,
      highlightColor: highlightColor,
      disabledColor: disabledColor,
      onPressed: onPressed,
      mouseCursor: mouseCursor,
      focusNode: focusNode,
      autofocus: autofocus,
      tooltip: tooltip,
      enableFeedback: enableFeedback,
      constraints: constraints,
      style: style,
      icon: AnimatedSwitcher(
        duration: duration,
        switchInCurve: curve,
        switchOutCurve: curve,
        transitionBuilder: transitionBuilder,
        child: KeyedSubtree(
          key: Key('FolderButton#$isOpen'),
          child: _effectiveIcon,
        ),
      ),
    );
  }
}
