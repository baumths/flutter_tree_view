import 'internal.dart';

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

/// A simple class to control the theming of [TreeView] and [NodeWidget].
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
    Color? lineColor,
    this.lineStyle = LineStyle.connected,
    this.lineThickness = 2.0,
    this.indent = 20.0,
    this.shouldDrawLinkLine = true,
    this.nodeTileColor,
    this.nodeSelectedTileColor,
    this.nodeHoverColor,
    this.nodeFocusColor,
    this.nodeShape,
  })  : _lineColor = lineColor,
        assert(
          indent >= lineThickness,
          'The indent must not be less than lineThickness',
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

  /// Used to calculate the spacing of each nesting level of [TreeNode].
  ///
  /// [TreeNode] indentation: `[TreeNode.depth] * [TreeViewTheme.indent]`.
  ///
  /// Defaults to `20.0`
  final double indent;

  /// The style used to draw the lines of [TreeView].
  ///
  /// Defaults to `LineStyle.connected`
  final LineStyle lineStyle;

  /// Whether or not a link line should be drawn to connect the parent node to
  /// its children lines, useful when the parent has margin/padding and the
  /// children lines doesn't connect to the bottom of it.
  ///
  /// This property only gets applied if [lineStyle] is either
  /// [LineStyle.connected] or [LineStyle.scoped].
  ///
  /// Defaults to `true`.
  final bool shouldDrawLinkLine;

  /// Defines the background color of `NodeWidget` when
  /// [TreeNode.isSelected] is false.
  ///
  /// When the value is null, the `nodeTileColor` is set to
  /// [ListTileTheme.tileColor] if it's not null and to
  /// [Colors.transparent] if it's null.
  final Color? nodeTileColor;

  /// Defines the background color of `NodeWidget` when
  /// [TreeNode.isSelected] is true.
  ///
  /// When the value is null, the `nodeSelectedTileColor` is set to
  /// [ListTileTheme.selectedTileColor] if it's not null and to
  /// [Colors.transparent] if it's null.
  final Color? nodeSelectedTileColor;

  /// The color for the node's [Material] when a pointer is hovering over it.
  final Color? nodeHoverColor;

  /// The color for the node's [Material] when it has the input focus.
  final Color? nodeFocusColor;

  /// The shape of [NodeWidget]'s [InkWell].
  ///
  /// Defines the [NodeWidget]'s [InkWell.customBorder].
  ///
  /// If this property is null then [CardTheme.shape] of
  /// [ThemeData.cardTheme] is used.
  /// If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 4.0.
  final ShapeBorder? nodeShape;

  @override
  int get hashCode => hashValues(
        lineStyle,
        lineStyle,
        lineThickness,
        indent,
        shouldDrawLinkLine,
        nodeTileColor,
        nodeSelectedTileColor,
        nodeHoverColor,
        nodeFocusColor,
        nodeShape,
      );

  @override
  bool operator ==(covariant TreeViewTheme other) {
    if (identical(this, other)) return true;
    return lineColor == other.lineColor &&
        lineStyle == other.lineStyle &&
        lineThickness == other.lineThickness &&
        indent == other.indent &&
        shouldDrawLinkLine == other.shouldDrawLinkLine &&
        nodeTileColor == other.nodeTileColor &&
        nodeSelectedTileColor == other.nodeSelectedTileColor &&
        nodeHoverColor == other.nodeHoverColor &&
        nodeFocusColor == other.nodeFocusColor &&
        nodeShape == other.nodeShape;
  }

  /// Returns a copy of this object with new attributes.
  TreeViewTheme copyWith({
    Color? lineColor,
    LineStyle? lineStyle,
    double? lineThickness,
    double? indent,
    bool? shouldDrawLinkLine,
    IconData? parentNodeIcon,
    IconData? leafNodeIcon,
    Color? nodeIconColor,
    Color? nodeTileColor,
    Color? nodeSelectedTileColor,
    Color? nodeHoverColor,
    Color? nodeFocusColor,
    ShapeBorder? nodeShape,
  }) {
    return TreeViewTheme(
      lineColor: lineColor ?? this.lineColor,
      lineStyle: lineStyle ?? this.lineStyle,
      lineThickness: lineThickness ?? this.lineThickness,
      indent: indent ?? this.indent,
      shouldDrawLinkLine: shouldDrawLinkLine ?? this.shouldDrawLinkLine,
      nodeTileColor: nodeTileColor ?? this.nodeTileColor,
      nodeSelectedTileColor:
          nodeSelectedTileColor ?? this.nodeSelectedTileColor,
      nodeHoverColor: nodeHoverColor ?? this.nodeHoverColor,
      nodeFocusColor: nodeFocusColor ?? this.nodeFocusColor,
      nodeShape: nodeShape ?? this.nodeShape,
    );
  }
}
