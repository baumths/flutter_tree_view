import 'internal.dart';

/// An wrapper around [ExpandIcon] with node toggling functionality.
class ExpandNodeIcon extends StatelessWidget {
  /// Creates an [ExpandNodeIcon].
  const ExpandNodeIcon({
    Key? key,
    this.size = 24.0,
    this.padding = const EdgeInsets.all(8.0),
    this.color,
    this.disabledColor,
    this.expandedColor,
  }) : super(key: key);

  /// The size of the icon.
  ///
  /// This property must not be null. It defaults to 24.0.
  ///
  /// `Copied from [ExpandIcon.size]`
  final double size;

  /// The padding around the icon. The entire padded icon will react to input
  /// gestures.
  ///
  /// This property must not be null. It defaults to 8.0 padding on all sides.
  ///
  /// `Copied from [ExpandIcon.padding]`
  final EdgeInsetsGeometry padding;

  /// The color of the icon.
  ///
  /// Defaults to [Colors.black54] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white60] when it is [Brightness.dark]. This adheres to the
  /// Material Design specifications for [icons](https://material.io/design/iconography/system-icons.html#color)
  /// and for [dark theme](https://material.io/design/color/dark-theme.html#ui-application)
  ///
  /// `Copied from [ExpandIcon.color]`
  final Color? color;

  /// The color of the icon when it is disabled,
  /// i.e. if [onToggle] is null.
  ///
  /// Defaults to [Colors.black38] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white38] when it is [Brightness.dark]. This adheres to the
  /// Material Design specifications for [icons](https://material.io/design/iconography/system-icons.html#color)
  /// and for [dark theme](https://material.io/design/color/dark-theme.html#ui-application)
  ///
  /// `Copied from [ExpandIcon.disabledColor]`
  final Color? disabledColor;

  /// The color of the icon when the icon is expanded.
  ///
  /// Defaults to [Colors.black54] when the theme's
  /// [ThemeData.brightness] is [Brightness.light] and to
  /// [Colors.white] when it is [Brightness.dark]. This adheres to the
  /// Material Design specifications for [icons](https://material.io/design/iconography/system-icons.html#color)
  /// and for [dark theme](https://material.io/design/color/dark-theme.html#ui-application)
  ///
  /// `Copied from [ExpandIcon.expandedColor]`
  final Color? expandedColor;

  @override
  Widget build(BuildContext context) {
    final scopedTreeNode = ScopedTreeNode.of(context);

    return ExpandIcon(
      size: size,
      color: color,
      disabledColor: disabledColor,
      expandedColor: expandedColor,
      padding: padding,
      isExpanded: scopedTreeNode.isExpanded,
      onPressed: scopedTreeNode.node.isLeaf
          ? null
          : (_) => scopedTreeNode.toggleExpanded(context),
    );
  }
}
