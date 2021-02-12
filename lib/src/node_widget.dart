import 'internal.dart';

/// A wrapper around [ListTile].
///
/// Most theming properties were moved to [TreeViewTheme].
///
/// Includes the indentation of nodes, the addition of Lines (if applicable),
/// the [ExpandNodeIcon] to the right of the Widget that already
/// expand/collapse the node and animate itself.
///
/// Take a look at the example in the
/// [online demo](https://mbaumgartenbr.github.io/flutter_tree_view).
class NodeWidget extends StatefulWidget {
  /// Creates a [NodeWidget].
  const NodeWidget({
    Key? key,
    required this.node,
    required this.theme,
    required this.title,
    this.useExpandNodeIcon = true,
    this.trailing = const [],
    this.contentPadding,
    this.horizontalTitleGap = 0,
    this.dense,
    this.onTap,
    this.onToggle,
    this.onLongPress,
  }) : super(key: key);

  /// The node to be displayed by this widget.
  final TreeNode node;

  /// The theme to be used for this widget.
  final TreeViewTheme theme;

  /// The Widget to be used as `title` of [ListTile].
  ///
  /// Usually a [Text] widget.
  final Widget title;

  /// If set to `false`, [ExpandNodeIcon] will be removed
  /// from the trailing of [ListTile].
  final bool useExpandNodeIcon;

  /// List of items to display in a [Row]
  /// before [ExpandNodeIcon] inside [ListTile.trailing]
  final List<Widget> trailing;

  /// The tile's internal padding. (Doesn't affect lines space)
  ///
  /// Insets a [ListTile]'s contents: its [leading], [title],
  /// [subtitle], and [trailing] widgets.
  ///
  /// `Copied from [ListTile.contentPadding].`
  ///
  /// If null, `EdgeInsets.zero` is used.
  final EdgeInsetsGeometry? contentPadding;

  /// The horizontal gap between the titles and the leading/trailing widgets.
  ///
  /// Defaults to 0.
  final double horizontalTitleGap;

  /// Whether this list tile is part of a vertically dense list.
  ///
  /// If this property is null then its value is based on [ListTileTheme.dense].
  ///
  /// Dense list tiles default to a smaller height.
  ///
  /// `Copied from [ListTile.dense].`
  final bool? dense;

  /// Callback for when user taps on a node.
  final VoidCallback? onTap;

  /// Callback for when a node is expanded/collapsed.
  final VoidCallback? onToggle;

  /// Callback for when user long presses a node.
  final VoidCallback? onLongPress;

  @override
  _NodeWidgetState createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  late double indentation;

  /// Calculates the indentation of [node] for the current [theme.lineStyle].
  double calculateIndentation() {
    var indentation = widget.node.calculateIndentation(widget.theme.indent);

    if (widget.theme.lineStyle == LineStyle.connected) {
      indentation += widget.theme.indent;
    }
    return indentation;
  }

  /// Updates the view.
  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.node.addUpdateCallback(update);
    indentation = calculateIndentation();
  }

  @override
  void didUpdateWidget(covariant NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    indentation = calculateIndentation();
  }

  @override
  void dispose() {
    widget.node.removeUpdateCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minLeadingWidth: indentation,
      horizontalTitleGap: widget.horizontalTitleGap,
      contentPadding: widget.contentPadding ?? EdgeInsets.zero,
      selected: widget.node.isSelected,
      enabled: widget.node.isEnabled,
      dense: widget.dense,
      tileColor: widget.theme.nodeTileColor,
      selectedTileColor: widget.theme.nodeSelectedTileColor,
      hoverColor: widget.theme.nodeHoverColor,
      focusColor: widget.theme.nodeFocusColor,
      shape: widget.theme.nodeShape,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      title: widget.title,
      trailing: _buildTrailing(),
      leading: LinesWidget(
        node: widget.node,
        theme: widget.theme,
      ),
    );
  }

  Widget? _buildTrailing() {
    if (widget.trailing.isEmpty) {
      return widget.useExpandNodeIcon && widget.node.hasChildren
          ? _expandIcon
          : null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.trailing,
        if (widget.node.hasChildren && widget.useExpandNodeIcon) _expandIcon,
      ],
    );
  }

  Widget get _expandIcon {
    return ExpandNodeIcon(
      node: widget.node,
      onToggle: widget.onToggle,
    );
  }
}

/// Widget responsible for indenting nodes and drawing lines (if enabled).
class LinesWidget extends StatelessWidget {
  /// Creates a [LinesWidget].
  const LinesWidget({
    Key? key,
    required this.node,
    required this.theme,
  }) : super(key: key);

  /// The node to draw lines for.
  final TreeNode node;

  /// The theme to use while drawing lines.
  final TreeViewTheme theme;

  /// Decides on which type of lines to draw for
  /// [node] based on [theme.lineStyle].
  Widget chooseLines({required Widget child}) {
    switch (theme.lineStyle) {
      case LineStyle.scoped:
        return CustomPaint(
          painter: LinesPainter.scoped(node: node, theme: theme),
          child: child,
        );
      case LineStyle.connected:
        return CustomPaint(
          painter: LinesPainter.connected(node: node, theme: theme),
          child: child,
        );
      case LineStyle.disabled:
      default:
        return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return chooseLines(
      child: SizedBox(
        width: node.calculateIndentation(theme.indent),
        height: double.infinity,
      ),
    );
  }
}
