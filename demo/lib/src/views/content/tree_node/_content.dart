part of 'tile.dart';

class NodeContent extends StatefulWidget {
  const NodeContent({
    super.key,
    this.actionsMenuKey,
    this.onHighlighted,
  });

  final GlobalKey<PopupMenuButtonState>? actionsMenuKey;
  final VoidCallback? onHighlighted;

  @override
  State<NodeContent> createState() => _NodeContentState();
}

class _NodeContentState extends State<NodeContent> {
  late DemoNode node;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    node = NodeScope.of(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color iconColor = colorScheme.onSurfaceVariant;
    // final Color iconColor = isHighlighted //
    //     ? colorScheme.onPrimary
    //     : colorScheme.onSurfaceVariant;

    Widget content = SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomFolderButton(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 4, 0),
            color: iconColor,
            node: node,
            onTap: () => SliverTree.of<DemoNode>(context).toggleExpansion(node),
          ),
          NodeActions(
            node: node,
            actionsMenyKey: widget.actionsMenuKey,
          ),
          const SizedBox(width: 8),
          Text(node.label),
        ],
      ),
    );

    // if (isHighlighted) {
    //   return HighlightDecoration(child: content);
    // }

    return content;
  }
}

class HighlightDecoration extends StatelessWidget {
  const HighlightDecoration({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: colorScheme.onPrimary),
        child: child,
      ),
    );
  }
}

class CustomFolderButton extends StatelessWidget {
  const CustomFolderButton({
    super.key,
    required this.node,
    this.color,
    this.padding,
    this.onTap,
  });

  final DemoNode node;

  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (node.children.isEmpty) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(Icons.article_outlined, color: color),
      );
    }

    return FolderButton(
      padding: padding ?? EdgeInsets.zero,
      color: color,
      isOpen: node.isExpanded,
      onPressed: onTap,
    );
  }
}
