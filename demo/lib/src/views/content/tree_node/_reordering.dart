part of 'tile.dart';

class NodeTileReordering extends ConsumerStatefulWidget {
  const NodeTileReordering({
    super.key,
    required this.child,
    required this.builder,
  });

  final Widget child;

  /// used to only wrap [child] in decorations when another node is hovering this
  /// node. when there's no node hovering, [builder] is called, passing [child]
  /// untouched, otherwise, builder is called with `NodeDropFeedback(child)`.
  final Widget Function(Widget child) builder;

  @override
  ConsumerState<NodeTileReordering> createState() => _NodeTileReorderingState();
}

class _NodeTileReorderingState extends ConsumerState<NodeTileReordering> {
  late DemoNode node;
  late TreeController<DemoNode> treeController;

  void onReorder(TreeReorderingDetails<DemoNode> details) {
    late final DemoNode newParent;
    late int newIndex;

    details.when<void>(
      above: () {
        newParent = details.targetNode.parent;
        newIndex = details.targetNode.index;
      },
      inside: () {
        newParent = details.targetNode;
        newIndex = newParent.children.length;
      },
      below: () {
        newParent = details.targetNode.parent;
        newIndex = details.targetNode.index + 1;
      },
    );

    newParent.insertChild(newIndex, details.draggedNode);

    if (!newParent.isExpanded) {
      treeController.expand(newParent);
    } else {
      treeController.rebuild();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    node = NodeScope.of(context);
    treeController = SliverTree.of<DemoNode>(context).controller;
  }

  @override
  Widget build(BuildContext context) {
    return TreeDraggable<DemoNode>(
      node: node,
      childWhenDragging: NodeWhenDragging(node: node),
      feedback: NodeDragFeedback(node: node),
      child: TreeDragTarget<DemoNode>(
        node: node,
        onReorder: onReorder,
        builder: (
          BuildContext context,
          TreeReorderingDetails<DemoNode>? details,
        ) {
          Widget content = widget.child;

          if (details != null) {
            content = NodeDropFeedback(
              details: details,
              child: content,
            );
          }

          return widget.builder(content);
        },
      ),
    );
  }
}

class NodeDragFeedback extends StatelessWidget {
  const NodeDragFeedback({super.key, required this.node});

  final DemoNode node;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foregroundColor = colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.drag_handle, color: foregroundColor),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 16, 8),
                child: Text(
                  node.label,
                  style: TextStyle(color: foregroundColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NodeWhenDragging extends StatelessWidget {
  const NodeWhenDragging({super.key, required this.node});

  final DemoNode node;

  @override
  Widget build(BuildContext context) {
    return const MouseRegion(
      cursor: SystemMouseCursors.noDrop,
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.5,
          child: TreeItem(
            child: NodeContent(),
          ),
        ),
      ),
    );
  }
}

class NodeDropFeedback extends StatelessWidget {
  const NodeDropFeedback({
    super.key,
    required this.child,
    required this.details,
  });

  final Widget child;
  final TreeReorderingDetails<DemoNode> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderSide = BorderSide(
      color: theme.colorScheme.onSurfaceVariant,
      width: 2.5,
    );

    final border = details.when<Border>(
      above: () => Border(top: borderSide),
      inside: () => Border.fromBorderSide(borderSide),
      below: () => Border(bottom: borderSide),
    );

    return DecoratedBox(
      decoration: BoxDecoration(border: border),
      child: child,
    );
  }
}
