import 'internal.dart';

class NodeWidget extends StatefulWidget {
  const NodeWidget({
    Key? key,
    required this.node,
    required this.title,
    required this.theme,
    required this.controller,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onToggle,
    this.onLongPress,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewTheme theme;
  final TreeViewController controller;

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final List<Widget>? trailing;

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
  late final TreeNode node;

  void update() => setState(() {});

  @override
  void initState() {
    super.initState();
    node = widget.node;
    node.addListener(update);
  }

  @override
  void dispose() {
    node.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      selected: node.isSelected,
      enabled: node.isEnabled,
      onTap: () => widget.onTap?.call(node),
      onLongPress: () => widget.onLongPress?.call(node),
      title: widget.title,
      trailing: node.hasChildren
          ? ToggleNodeIconButton(
              node: node,
              onToggle: widget.onToggle,
              controller: widget.controller,
            )
          : null,
      leading: Padding(
        padding: EdgeInsets.only(left: indentation),
        child: SizedBox(
          height: double.infinity,
          child: widget.leading ??
              Icon(
                node.hasChildren ? Icons.folder : Icons.article,
                color: Theme.of(context).accentColor,
              ),
        ),
      ).lines(node, widget.theme),
    );
  }

  double get indentation {
    return widget.theme.lineStyle == LineStyle.connected
        ? node.depth * widget.theme.singleLineWidth
        : (node.depth - 1) * widget.theme.singleLineWidth;
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
      onPressed: (_) {
        node.isExpanded
            ? controller.collapseNode(node)
            : controller.expandNode(node);
        onToggle?.call(node);
      },
    );
  }
}

extension LineX on Widget {
  /// Extension that decides how to draw lines based on [TreeViewTheme.lineStyle].
  Widget lines(TreeNode node, TreeViewTheme theme) {
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
