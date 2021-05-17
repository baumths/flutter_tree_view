import 'package:flutter/material.dart';

/// Defines the style of lines.
enum LineStyle {
  /// Makes the tree less expensive removing [CustomPainter] completely
  /// from the widget tree.
  disabled,

  /// Draws lines that connects to the side of the nodes.
  connected,

  /// Draws straight lines prefixing blocks of child nodes.
  scoped,
}

/// A simple class to control the theming of [TreeView].
///
/// Makes it easy to customize [NodeWidget] and [LinesWidget].
///
/// Example of indent & lineThickness relationship.
/// ```dart
///  /*             <- indent ->
///    -------------------------------------
///    |                 |                 |
///    |                 |                 |
///    |               <-|-> lineThickness |
///    |                 |                 |
///    |                 |                 |
///    -------------------------------------  */
/// ```
/// A single line will be drawn at the middle of [indent] with
/// thickness of [lineThickness] as shown above.
///
/// Play around to find the combination of values that better fits you.
///
/// Make sure `indent >= lineThickness`.
class TreeViewTheme {
  /// Creates a [TreeViewTheme].
  const TreeViewTheme({
    this.lineColor = Colors.grey,
    this.lineStyle = LineStyle.connected,
    this.lineThickness = 2.0,
    this.indent = 40.0,
    this.roundLineCorners = false,
  }) : assert(
          indent >= lineThickness,
          'The indent must not be less than lineThickness',
        );

  /// The color used to draw the lines.
  ///
  /// Defaults to `Colors.grey`
  final Color lineColor;

  /// The width of a single line.
  ///
  /// Defaults to `2.0`
  final double lineThickness;

  /// Used to calculate the spacing of each nesting level of [TreeNode].
  ///
  /// [TreeNode] indentation: `[TreeNode.depth] * [TreeViewTheme.indent]`.
  ///
  /// Defaults to `40.0`
  final double indent;

  /// The style used to draw the lines of [TreeView].
  ///
  /// Defaults to `LineStyle.connected`
  final LineStyle lineStyle;

  /// Set to `true` if you want to round the corners of [LineStyle.connected].
  ///
  /// Defaults to `false`.
  final bool roundLineCorners;

  @override
  int get hashCode => hashValues(
        lineStyle,
        lineStyle,
        lineThickness,
        indent,
        roundLineCorners,
      );

  @override
  bool operator ==(covariant TreeViewTheme other) {
    if (identical(this, other)) return true;

    return lineColor == other.lineColor &&
        lineStyle == other.lineStyle &&
        lineThickness == other.lineThickness &&
        indent == other.indent &&
        roundLineCorners == other.roundLineCorners;
  }

  /// Returns a copy of this object with new attributes.
  TreeViewTheme copyWith({
    Color? lineColor,
    LineStyle? lineStyle,
    double? lineThickness,
    double? indent,
    bool? roundLineCorners,
  }) {
    return TreeViewTheme(
      lineColor: lineColor ?? this.lineColor,
      lineStyle: lineStyle ?? this.lineStyle,
      lineThickness: lineThickness ?? this.lineThickness,
      indent: indent ?? this.indent,
      roundLineCorners: roundLineCorners ?? this.roundLineCorners,
    );
  }
}
