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
  final TreeViewCallback? onTap;

  /// Callback for when a node is expanded/collapsed.
  final TreeViewCallback? onToggle;

  /// Callback for when user long presses a node.
  final TreeViewCallback? onLongPress;

  @override
  _NodeWidgetState createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.node.addListener(update);
  }

  @override
  void dispose() {
    widget.node.removeListener(update);
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
      onTap: widget.onTap == null ? null : () => widget.onTap!(widget.node),
      onLongPress: widget.onLongPress == null
          ? null
          : () => widget.onLongPress!(widget.node),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.trailing,
          if (widget.node.hasChildren)
            ToggleNodeIconButton(
              node: widget.node,
              onToggle: widget.node.isEnabled ? widget.onToggle : null,
              controller: widget.controller,
            ),
        ],
      ),
      leading: LinesWidget(
        indentation: indentation,
        child: widget.leading ?? _buildLeading(),
      ).chooseLines(widget.node, widget.theme),
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

  double get indentation {
    return widget.theme.lineStyle == LineStyle.connected
        ? widget.node.depth * widget.theme.singleLineWidth
        : (widget.node.depth - 1) * widget.theme.singleLineWidth;
  }
}

class ToggleNodeIconButton extends StatelessWidget {
  const ToggleNodeIconButton({
    Key? key,
    required this.node,
    required this.controller,
    required this.onToggle,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewController controller;
  final TreeViewCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return ExpandIcon(
      padding: EdgeInsets.zero,
      isExpanded: node.isExpanded,
      onPressed: node.isEnabled
          ? (_) {
              node.toggleExpanded();
              onToggle?.call(node);
            }
          : null,
    );
  }
}

/// Uses [animation] to animate [child] with [SizeTransition] & [FadeTransition].
class SizeAndFadeAnimatedWidget extends StatelessWidget {
  const SizeAndFadeAnimatedWidget({
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

/// Wraps [child] in a [SizedBox] with height of `double.infinity`
/// and adds left padding of [indentation].
///
/// Used to draw lines for [NodeWidget].
///
/// Usage:
/// ```dart
/// LinesWidget(/* ... */).chooseLines(TreeNode, TreeViewTheme);
/// ```
///
/// The `chooseLines` method wraps [LinesWidget] in a [CustomPaint] *if needed*.
/// It was extracted as an extension to remove the many `if` checks from
/// the `build` method.
class LinesWidget extends StatelessWidget {
  const LinesWidget({
    Key? key,
    required this.indentation,
    this.child,
  }) : super(key: key);

  final Widget? child;
  final double indentation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indentation),
      child: SizedBox(
        height: double.infinity,
        child: child,
      ),
    );
  }
}

extension LineX on LinesWidget {
  /// Extension that decides how to draw lines based on [TreeViewTheme.lineStyle].
  Widget chooseLines(TreeNode node, TreeViewTheme theme) {
    switch (theme.lineStyle) {
      case LineStyle.scoped:
        return CustomPaint(
          painter: LinesPainter.scoped(node: node, theme: theme),
          child: this,
        );
      case LineStyle.connected:
        return CustomPaint(
          painter: LinesPainter.connected(node: node, theme: theme),
          child: this,
        );
      case LineStyle.disabled:
      default:
        return this;
    }
  }
}
