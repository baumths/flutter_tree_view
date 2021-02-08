import 'internal.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget({
    Key? key,
    required this.node,
    required this.title,
    required this.theme,
    required this.controller,
    this.trailing = const [],
    this.leading,
    this.contentPadding,
    this.horizontalTitleGap,
    this.dense,
    this.onTap,
    this.onToggle,
    this.onLongPress,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewTheme theme;
  final TreeViewController controller;

  /// The Widget to be used as `title` of [ListTile].
  ///
  /// Usually a [Text] widget.
  final Widget title;

  /// Widget to use as leading of [ListTile].
  ///
  /// If null, defaults to an [Icon] customized by [TreeViewTheme].
  final Widget? leading;

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
  /// If null, then the value of [ListTileTheme.horizontalTitleGap] is used.
  /// If that is also null, then a default value of 16 is used.
  ///
  /// `Copied from [ListTile.horizontalTitleGap].`
  final double? horizontalTitleGap;

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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      horizontalTitleGap: widget.horizontalTitleGap,
      contentPadding: widget.contentPadding ?? EdgeInsets.zero,
      selected: widget.node.isSelected,
      enabled: widget.node.isEnabled,
      dense: widget.dense,
      title: widget.title,
      tileColor: widget.theme.nodeTileColor,
      selectedTileColor: widget.theme.nodeSelectedTileColor,
      hoverColor: widget.theme.nodeHoverColor,
      focusColor: widget.theme.nodeFocusColor,
      shape: widget.theme.nodeShape,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      trailing: _buildTrailing(),
      leading: LinesWidget(
        node: widget.node,
        theme: widget.theme,
        child: widget.leading ?? _buildLeading(),
      ),
    );
  }

  Icon? _buildLeading() {
    final color = widget.theme.nodeIconColor ?? Theme.of(context).accentColor;
    if (widget.node.hasChildren) {
      if (widget.theme.parentNodeIcon == null) return null;
      return Icon(widget.theme.parentNodeIcon, color: color);
    }
    if (widget.theme.leafNodeIcon == null) return null;
    return Icon(widget.theme.leafNodeIcon, color: color);
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
    return ToggleNodeIconButton(
      node: widget.node,
      onToggle: widget.node.isEnabled ? widget.onToggle : null,
      controller: widget.controller,
    );
  }
}

/// Creates an [ExpandIcon] Widget with toggling node functionality.
class ToggleNodeIconButton extends StatelessWidget {
  const ToggleNodeIconButton({
    Key? key,
    required this.node,
    required this.controller,
    required this.onToggle,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewController controller;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return ExpandIcon(
      padding: EdgeInsets.zero,
      isExpanded: node.isExpanded,
      onPressed: node.isEnabled
          ? (_) {
              node.toggleExpanded();
              onToggle?.call();
            }
          : null,
    );
  }
}

/// Uses [animation] to animate [child] with [SizeTransition] & [FadeTransition].
class SizeAndFadeTransition extends StatelessWidget {
  const SizeAndFadeTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Widget responsible for indenting nodes and drawing lines (if enabled).
class LinesWidget extends StatelessWidget {
  const LinesWidget({
    Key? key,
    required this.node,
    required this.theme,
    this.child,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewTheme theme;

  final Widget? child;

  double get indentation {
    return theme.lineStyle == LineStyle.connected
        ? (node.depth + 1) * theme.singleLineWidth
        : node.depth * theme.singleLineWidth;
  }

  Padding _buildPadding() {
    return Padding(
      padding: EdgeInsets.only(left: indentation),
      child: SizedBox(
        height: double.infinity,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (theme.lineStyle) {
      case LineStyle.scoped:
        return CustomPaint(
          painter: LinesPainter.scoped(node: node, theme: theme),
          child: _buildPadding(),
        );
      case LineStyle.connected:
        return CustomPaint(
          painter: LinesPainter.connected(node: node, theme: theme),
          child: _buildPadding(),
        );
      case LineStyle.disabled:
      default:
        return _buildPadding();
    }
  }
}
