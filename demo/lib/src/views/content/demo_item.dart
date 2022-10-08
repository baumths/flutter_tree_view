import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings.dart';
import '../../providers/tree.dart';
import 'folder_button.dart';

final treeEntryProvider = Provider<TreeEntry<DemoNode>>(
  (ref) => throw UnimplementedError(),
);

class DemoItem extends ConsumerStatefulWidget {
  const DemoItem({super.key, required this.treeEntry});

  final TreeEntry<DemoNode> treeEntry;

  @override
  ConsumerState<DemoItem> createState() => _DemoItemState();
}

class _DemoItemState extends ConsumerState<DemoItem> {
  TreeEntry<DemoNode> get treeEntry => widget.treeEntry;
  DemoNode get node => treeEntry.node;

  late TreeNavigationState<DemoNode>? treeNavigation;

  late final focusNode = FocusNode();

  bool isHighlighted = false;
  bool isLoading = false;

  // Used when a reordering node is hovering this node in the top half of
  // this widget's height.
  bool hoveringNodeIsAbove = false;

  void toggle() => ref.read(treeControllerProvider).toggleExpansion(node);

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
    final double y = details.dropPosition.dy;
    final double heightFactor = details.targetBounds.height / 2;
    final bool isAbove = y <= heightFactor;

    late DemoNode target = details.targetNode;
    late int index = 0;

    if (isAbove) {
      target = details.targetNode.parent ?? DemoNode.root;
      index = details.targetNode.index;
    } else {
      if (!details.targetNode.isExpanded) {
        index = details.targetNode.children.length;
      }
    }

    target.insertChild(index, details.draggedNode);
    ref.read(treeControllerProvider).rebuild();
    treeNavigation?.highlight(details.draggedNode);
  }

  Widget decorationBuilder(
    BuildContext context,
    Widget child,
    TreeReorderingDetails<DemoNode> details,
  ) {
    final double y = details.dropPosition.dy;
    final double heightFactor = details.targetBounds.height / 2;
    final bool isAbove = y <= heightFactor;

    hoveringNodeIsAbove = isAbove;

    final virtualEntry = TreeEntry<DemoNode>(
      node: details.draggedNode,
      index: -1,
      level: treeEntry.level + (isAbove ? 0 : 1),
      parent: isAbove ? treeEntry.parent : treeEntry,
      hasNextSibling: isAbove ? true : node.isExpanded && node.hasChildren,
    );

    final incoming = VirtualTreeItem(
      treeEntry: virtualEntry,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: isAbove ? [incoming, child] : [child, incoming],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ref.watch(colorSchemeProvider);

    Widget content = SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DemoFolderButton(
            onTap: toggle,
            isLoading: isLoading,
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
      content = DecoratedBox(
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

    return ReorderableTreeItem<DemoNode>(
      treeEntry: treeEntry,
      focusNode: focusNode,
      focusColor: Colors.transparent,
      onTap: highlight,
      onReorder: onReorder,
      decorationWrapsChildOnly: false,
      canStartToggleExpansionTimer: () => !hoveringNodeIsAbove,
      decorationBuilder: decorationBuilder,
      childWhenDragging: Opacity(
        opacity: 0.6,
        child: TreeIndentation(
          treeEntry: treeEntry,
          child: content,
        ),
      ),
      feedback: const SizedBox(),
      child: content,
    );
  }
}

class VirtualTreeItem extends StatelessWidget {
  const VirtualTreeItem({
    super.key,
    required this.treeEntry,
  });

  final TreeEntry<DemoNode> treeEntry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final foregroundColor = colorScheme.onSecondary;

    return TreeItem<DemoNode>(
      treeEntry: treeEntry,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.drag_handle, color: foregroundColor),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: Text(
                      treeEntry.node.label,
                      style: TextStyle(color: foregroundColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
