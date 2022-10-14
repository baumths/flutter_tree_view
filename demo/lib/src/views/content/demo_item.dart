import 'package:flutter/material.dart';

import '../../providers/tree.dart';
import 'folder_button.dart';

class DemoItem extends StatefulWidget {
  const DemoItem({super.key, required this.node});

  final DemoNode node;

  @override
  State<DemoItem> createState() => _DemoItemState();
}

class _DemoItemState extends State<DemoItem> {
  DemoNode get node => widget.node;

  late TreeNavigationState<DemoNode>? treeNavigation;
  late TreeController<DemoNode> treeController;

  late final focusNode = FocusNode();

  void toggle() => treeController.toggleExpansion(node);

  void toggleCascading() {
    node.isExpanded
        ? treeController.collapseCascading(node)
        : treeController.expandCascading(node);
  }

  bool isHighlighted = false;
  bool get showHighlight => _showHighlight;
  bool _showHighlight = true;
  set showHighlight(bool value) {
    if (_showHighlight == value) return;
    setState(() {
      _showHighlight = value;
    });
  }

  void highlight() {
    if (isHighlighted) {
      toggle();
    } else {
      treeNavigation?.highlight(node);
    }
  }

  VerticalEdgeDraggingAutoScroller? autoScroller;

  void _updateAutoScroller() {
    final ScrollableState scrollable = Scrollable.of(context)!;

    if (autoScroller?.scrollable != scrollable) {
      autoScroller?.stopAutoScroll();
      autoScroller = VerticalEdgeDraggingAutoScroller(
        scrollable: scrollable,
        onScrollViewScrolled: () => autoScroller?.stopAutoScroll(),
      );
    }
  }

  void _maybeAutoScroll() {
    if (autoScroller == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject()! as RenderBox;
      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
      autoScroller!.startAutoScrollIfNecessary(rect.inflate(10));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAutoScroller();

    treeController = SliverTree.of<DemoNode>(context).controller;
    treeNavigation = TreeNavigation.of<DemoNode>(context);
    isHighlighted = treeNavigation?.currentHighlight == node;

    if (isHighlighted && !focusNode.hasFocus) {
      focusNode.requestFocus();
      _maybeAutoScroll();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  void onReorder(TreeReorderingDetails<DemoNode> details) {
    late final DemoNode newParent;
    late int newIndex;

    details.when<void>(
      above: () {
        newParent = details.targetNode.parent ?? treeController.root;
        newIndex = details.targetNode.index;
      },
      inside: () {
        newParent = details.targetNode;
        newIndex = newParent.children.length;
      },
      below: () {
        newParent = details.targetNode.parent ?? treeController.root;
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
  Widget build(BuildContext context) {
    return TreeDraggable<DemoNode>(
      node: node,
      childWhenDragging: NodeWhenDragging(node: node),
      feedback: const SizedBox(),
      child: TreeDragTarget<DemoNode>(
        node: node,
        onReorder: onReorder,
        canStartToggleExpansionTimer: () => true,
        onMove: (_) {
          if (isHighlighted) {
            showHighlight = false;
          }
        },
        onAccept: (_) => showHighlight = true,
        onLeave: (_) => showHighlight = true,
        builder: (
          BuildContext context,
          TreeReorderingDetails<DemoNode>? details,
        ) {
          Widget content = NodeContent(
            node: node,
            isHighlighted: showHighlight && isHighlighted,
            onTap: toggle,
          );

          if (details != null) {
            content = NodeDropFeedback(
              details: details,
              child: content,
            );
          }

          return TreeItem(
            focusNode: focusNode,
            focusColor: Colors.transparent,
            mouseCursor: SystemMouseCursors.grab,
            onTap: highlight,
            onLongPress: toggleCascading,
            child: content,
          );
        },
      ),
    );
  }
}

class NodeContent extends StatelessWidget {
  const NodeContent({
    super.key,
    required this.node,
    this.isHighlighted = false,
    this.onTap,
  });

  final DemoNode node;
  final bool isHighlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget content = SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DemoFolderButton(
            onTap: onTap,
            isLeaf: node.isLeaf,
            isOpen: node.isExpanded,
            color: isHighlighted
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
          Text(node.label),
        ],
      ),
    );

    if (isHighlighted) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: colorScheme.onPrimary),
          child: content,
        ),
      );
    }
    return content;
  }
}

class NodeWhenDragging extends StatelessWidget {
  const NodeWhenDragging({super.key, required this.node});

  final DemoNode node;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.5,
        child: TreeItem(
          child: NodeContent(node: node),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: DecoratedBox(
        decoration: BoxDecoration(border: border),
        child: child,
      ),
    );
  }
}

extension<T extends TreeNode<T>> on TreeReorderingDetails<T> {
  R when<R>({
    required R Function() above,
    required R Function() inside,
    required R Function() below,
  }) {
    final double y = dropPosition.dy;
    final double heightFactor = targetBounds.height / 3;

    if (y <= heightFactor) {
      return above();
    } else if (y <= heightFactor * 2) {
      return inside();
    } else {
      return below();
    }
  }
}
