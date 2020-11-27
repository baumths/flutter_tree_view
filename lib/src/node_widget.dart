import 'internal.dart';

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

class NodeWidget extends StatelessWidget {
  const NodeWidget({
    Key? key,
    required this.animation,
    required this.node,
    required this.nodeBuilder,
    required this.controller,
    required this.theme,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final Animation<double> animation;

  final TreeNode node;
  final TreeViewTheme theme;
  final TreeViewController controller;

  final NodeBuilder nodeBuilder;
  final TreeViewCallback? onTap;
  final TreeViewCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(node),
      onLongPress: onTap == null ? null : () => onLongPress!(node),
      child: AnimatedNode(
        animation: animation,
        child: Padding(
          padding: EdgeInsets.only(left: indentation),
          child: nodeBuilder(context, node),
        ).lines(node, theme),
      ),
    );
  }

  double get indentation {
    return theme.lineStyle == LineStyle.connected
        ? node.depth * theme.singleLineWidth
        : (node.depth - 1) * theme.singleLineWidth;
  }
}

class AnimatedNode extends StatelessWidget {
  const AnimatedNode({
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

extension LineX on Padding {
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
