import 'internal.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget({
    Key? key,
    required this.node,
    required this.title,
    required this.theme,
    this.trailing = const [],
    this.contentPadding,
    this.horizontalTitleGap = 0,
    this.dense,
    this.onTap,
    this.onToggle,
    this.onLongPress,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewTheme theme;

  /// The Widget to be used as `title` of [ListTile].
  ///
  /// Usually a [Text] widget.
  final Widget title;

  /// List of items to display in a [Row]
  /// before [ToggleNodeIconButton] inside [ListTile.trailing]
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
  /// Updates the view.
  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.node.addUpdateCallback(update);
  }

  @override
  void dispose() {
    widget.node.removeUpdateCallback();
    super.dispose();
  }

  /// Calculates the indentation of [node] for the current [theme.lineStyle].
  double calculateIndentation() {
    double indentation = widget.node.depth * widget.theme.indent;

    if (widget.theme.lineStyle == LineStyle.connected) {
      indentation += widget.theme.indent;
    }
    return indentation;
  }

  @override
  Widget build(BuildContext context) {
    final indentation = calculateIndentation();

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
        indentation: indentation,
      ),
    );
  }

  Widget? _buildTrailing() {
    if (widget.trailing.isEmpty) {
      return widget.node.hasChildren ? _expandIcon : null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.trailing,
        if (widget.node.hasChildren) _expandIcon,
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
    required this.indentation,
    this.child,
  }) : super(key: key);

  /// The node to draw lines for.
  final TreeNode node;

  /// The theme to use while drawing lines.
  final TreeViewTheme theme;

  /// The widget to be displayed to the right of the lines.
  final Widget? child;

  /// The left padding of [node].
  final double indentation;

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
        width: indentation,
        height: double.infinity,
        child: child,
      ),
    );
  }
}
