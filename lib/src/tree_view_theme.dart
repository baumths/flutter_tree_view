import 'internal.dart';

/// Defines the style of lines.
enum LineStyle {
  /// Disable lines, makes the tree less expensive.
  disabled,

  /// Draws the horizontal line that connects to the side of the nodes.
  connected,

  /// Not implemented yet
  scoped,
}

/// Class to control how the theme of the [TreeView].
///
/// A single line will be drawn at the middle of [singleLineWidth] with
/// thickness of [lineThickness] as shown below, play around to find the
/// combination of values that better fits you.
/// Make sure `singleLineWidth >= lineThickness`.
///
/// ```dart
///  /*        <- singleLineWidth ->
///    -------------------------------------
///    |                 |                 |
///    |                 |                 |
///    |               <-|-> lineThickness |
///    |                 |                 |
///    |                 |                 |
///    -------------------------------------  */
/// ```
///
///
class TreeViewTheme {
  /// Constructor for [TreeViewTheme].
  const TreeViewTheme({
    Color? lineColor,
    this.lineStyle = LineStyle.connected,
    this.lineThickness = 2.0,
    this.singleLineWidth = 24.0,
    this.shouldDrawLinkLine = true,
  })  : _lineColor = lineColor,
        assert(
          singleLineWidth >= lineThickness,
          "The width of a line must not be smaller than it's thickness",
        );

  /// The color used to draw the lines.
  ///
  /// Defaults to `Colors.grey.shade400`
  Color get lineColor => _lineColor ?? Colors.grey.shade400;
  final Color? _lineColor;

  /// The width of a single line.
  ///
  /// Defaults to `2.0`
  final double lineThickness;

  /// The space a single line occupies, the line will be drawn in
  /// the middle of this space.
  ///
  /// The total node left padding is calculated based on the number of lines
  /// multiplied by [singleLineWidth], therefore, the smaller the width,
  /// less space the node is going to take.
  ///
  /// Defaults to `24.0`
  final double singleLineWidth;

  /// The mode to style the lines of the [TreeView].
  ///
  /// Defaults to `LineStyle.connected`
  final LineStyle lineStyle;

  /// Whether or not a link line should be drawn to connect the parent node to
  /// its children lines, useful when the parent has margin/padding and the
  /// children lines doesn't connect to the bottom of it.
  ///
  /// This property only gets applied if [lineStyle] is [LineStyle.connected]
  ///
  /// Defaults to `true`.
  final bool shouldDrawLinkLine;

  @override
  int get hashCode => hashValues(
        lineStyle,
        lineStyle,
        lineThickness,
        singleLineWidth,
        shouldDrawLinkLine,
      );

  @override
  bool operator ==(covariant TreeViewTheme other) {
    if (identical(this, other)) return true;
    return lineColor == other.lineColor &&
        lineStyle == other.lineStyle &&
        lineThickness == other.lineThickness &&
        singleLineWidth == other.singleLineWidth &&
        shouldDrawLinkLine == other.shouldDrawLinkLine;
  }

  TreeViewTheme copyWith({
    Color? lineColor,
    LineStyle? lineStyle,
    double? lineThickness,
    double? singleLineWidth,
    bool? shouldDrawLinkLine,
  }) {
    return TreeViewTheme(
      lineColor: lineColor ?? this.lineColor,
      lineStyle: lineStyle ?? this.lineStyle,
      lineThickness: lineThickness ?? this.lineThickness,
      singleLineWidth: singleLineWidth ?? this.singleLineWidth,
      shouldDrawLinkLine: shouldDrawLinkLine ?? this.shouldDrawLinkLine,
    );
  }
}
