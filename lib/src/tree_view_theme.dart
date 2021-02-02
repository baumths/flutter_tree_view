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
    this.parentNodeIcon = Icons.folder,
    this.leafNodeIcon = Icons.article,
    this.nodeIconColor,
    this.nodeTileColor,
    this.nodeSelectedTileColor,
    this.nodeHoverColor,
    this.nodeFocusColor,
    this.nodeShape,
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

  /// The style used to draw the lines of [TreeView].
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

  /* * Properties applied to [ NodeWidget ] */

  /// The icon used as leading for [NodeWidget] when the node has children.
  ///
  /// If null, no icon will be displayed.
  ///
  /// Defaults to [Icons.folder].
  final IconData? parentNodeIcon;

  /// The icon used as leading for [NodeWidget] when the node is a leaf (no children).
  ///
  /// If null, no icon will be displayed.
  ///
  /// Defaults to [Icons.article].
  final IconData? leafNodeIcon;

  /// The color used for both [parentNodeIcon] and [leafNodeIcon].
  ///
  /// If null, [Theme.of(context).accentColor] will be used.
  final Color? nodeIconColor;

  /// Defines the background color of `NodeWidget` when [TreeNode.isSelected] is false.
  ///
  /// When the value is null, the `nodeTileColor` is set to
  /// [ListTileTheme.tileColor] if it's not null and to
  /// [Colors.transparent] if it's null.
  final Color? nodeTileColor;

  /// Defines the background color of `NodeWidget` when [TreeNode.isSelected] is true.
  ///
  /// When the value is null, the `nodeSelectedTileColor` is set to
  /// [ListTileTheme.selectedTileColor] if it's not null and to
  /// [Colors.transparent] if it's null.
  final Color? nodeSelectedTileColor;

  /// The color for the node's [Material] when a pointer is hovering over it.
  final Color? nodeHoverColor;

  /// The color for the node's [Material] when it has the input focus.
  final Color? nodeFocusColor;

  /// The shape of the node's [InkWell].
  ///
  /// Defines the node's [InkWell.customBorder].
  ///
  /// If this property is null then [CardTheme.shape] of [ThemeData.cardTheme] is used.
  /// If that's null then the shape will be a [RoundedRectangleBorder]
  /// with a circular corner radius of 4.0.
  final ShapeBorder? nodeShape;

  @override
  int get hashCode => hashValues(
        lineStyle,
        lineStyle,
        lineThickness,
        singleLineWidth,
        shouldDrawLinkLine,
        parentNodeIcon,
        leafNodeIcon,
        nodeIconColor,
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
        singleLineWidth == other.singleLineWidth &&
        shouldDrawLinkLine == other.shouldDrawLinkLine &&
        parentNodeIcon == other.parentNodeIcon &&
        leafNodeIcon == other.leafNodeIcon &&
        nodeIconColor == other.nodeIconColor &&
        nodeTileColor == other.nodeTileColor &&
        nodeSelectedTileColor == other.nodeSelectedTileColor &&
        nodeHoverColor == other.nodeHoverColor &&
        nodeFocusColor == other.nodeFocusColor &&
        nodeShape == other.nodeShape;
  }

  TreeViewTheme copyWith({
    Color? lineColor,
    LineStyle? lineStyle,
    double? lineThickness,
    double? singleLineWidth,
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
      singleLineWidth: singleLineWidth ?? this.singleLineWidth,
      shouldDrawLinkLine: shouldDrawLinkLine ?? this.shouldDrawLinkLine,
      parentNodeIcon: parentNodeIcon ?? this.parentNodeIcon,
      leafNodeIcon: leafNodeIcon ?? this.leafNodeIcon,
      nodeIconColor: nodeIconColor ?? this.nodeIconColor,
      nodeTileColor: nodeTileColor ?? this.nodeTileColor,
      nodeSelectedTileColor:
          nodeSelectedTileColor ?? this.nodeSelectedTileColor,
      nodeHoverColor: nodeHoverColor ?? this.nodeHoverColor,
      nodeFocusColor: nodeFocusColor ?? this.nodeFocusColor,
      nodeShape: nodeShape ?? this.nodeShape,
    );
  }
}
