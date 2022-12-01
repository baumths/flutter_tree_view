import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../example_node.dart';
import '../pages.dart' show PageInfo;

class ReorderableTreeView extends StatefulWidget with PageInfo {
  const ReorderableTreeView({super.key});

  @override
  String get title => 'Reorderable TreeView';

  @override
  String? get description {
    return 'Tap and hold a node to start dragging. '
        'In this example, when hovering a node, there are three available '
        'vertical segments to release the drop (represented by decoration '
        'borders):'
        '\nAbove: reorder as previous sibling'
        '\nCenter: reorder as last child'
        '\nBelow: reorder as next sibling';
  }

  @override
  State<ReorderableTreeView> createState() => _ReorderableTreeViewState();
}

typedef DecorationBuilder = Widget Function(
  BuildContext context,
  Widget child,
  TreeReorderingDetails<ExampleNode> details,
);

/// Simple extension that divides the [TreeReorderingDetails.targetBounds] into
/// three segments and applies a callback when the [TreeReorderingDetails.dropPosition]
/// is inside the segment handled by that callback.
///
/// This way of handling reordering as well as the values below are very opinionated.
extension<T extends TreeNode<T>> on TreeReorderingDetails<T> {
  R when<R>({
    required R Function() above,
    required R Function() inside,
    required R Function() below,
  }) {
    final double y = dropPosition.dy;
    final double heightFactor = targetBounds.height / 3;

    if (y <= heightFactor) {
      // top segment, could reorder as parent or previous sibling of target
      return above();
    } else if (y <= heightFactor * 2) {
      // center segment, could reorder as first or last child of target
      return inside();
    } else {
      // bottom segment, could reorder as first child or next sibling of target
      return below();
    }
  }
}

class _ReorderableTreeViewState extends State<ReorderableTreeView> {
  late final ExampleNode virtualRoot;
  late final ExampleTreeController treeController;

  @override
  void initState() {
    super.initState();
    virtualRoot = createSampleTree(ExampleNode.new);
    treeController = ExampleTreeController();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  void _onReorder(TreeReorderingDetails<ExampleNode> details) {
    late final ExampleNode newParent;
    late int newIndex;

    // Opinionated values.
    // `when` is defined as an extension at the end of this file.
    details.when<void>(
      above: () {
        // drop `details.draggedNode` as previous sibling of `details.targetNode`
        newParent = details.targetNode.parent ?? virtualRoot;
        newIndex = newParent.children.indexOf(details.targetNode);
      },
      inside: () {
        // drop `details.draggedNode` as the last child of `details.targetNode`
        newParent = details.targetNode;
        newIndex = newParent.children.length;
      },
      below: () {
        // drop `details.draggedNode` as next sibling of `details.targetNode`
        newParent = details.targetNode.parent ?? virtualRoot;
        newIndex = newParent.children.indexOf(details.targetNode) + 1;
      },
    );

    // Take a look at [ExampleNode.insertChild] which handles reparenting and
    // index clashes.
    newParent.insertChild(newIndex, details.draggedNode);

    // Make sure the new parent is expanded so the reordered node is shown.
    newParent.isExpanded = true;

    // Rebuild the flattened tree to make sure the changes are shown.
    treeController.rebuild();

    briefHighlight(details.draggedNode.key);
  }

  @override
  Widget build(BuildContext context) {
    late final highlightColor = Theme.of(context) //
        .colorScheme
        .primary
        .withOpacity(.3);

    return DefaultIndentGuide(
      guide: const ScopingLinesGuide(indent: 20, origin: 1),
      child: TreeView<ExampleNode>(
        roots: virtualRoot.children,
        controller: treeController,
        itemBuilder: (BuildContext context, TreeEntry<ExampleNode> entry) {
          // The [ReorderableTreeNodeTile] widget can be found down below.
          final Widget tile = ReorderableTreeNodeTile(
            node: entry.node,
            onReorder: _onReorder,
            onFolderPressed: () => treeController.toggleExpansion(entry.node),
          );

          if (highlightedKey == entry.node.key) {
            return Material(
              color: highlightColor,
              child: tile,
            );
          }

          return tile;
        },
      ),
    );
  }

  // opinionated way of highlighting a node after been reordered
  Timer? highlightTimer;
  int? highlightedKey;

  void briefHighlight(int key) {
    highlightTimer?.cancel();

    setState(() {
      highlightedKey = key;
    });

    highlightTimer = Timer(
      const Duration(seconds: 2),
      () {
        highlightedKey = null;
        if (mounted) setState(() {});
      },
    );
  }
}

class ReorderableTreeNodeTile extends StatefulWidget {
  const ReorderableTreeNodeTile({
    super.key,
    required this.node,
    required this.onReorder,
    this.onFolderPressed,
  });

  final ExampleNode node;
  final TreeOnReorderCallback<ExampleNode> onReorder;
  final VoidCallback? onFolderPressed;

  @override
  State<ReorderableTreeNodeTile> createState() =>
      _ReorderableTreeNodeTileState();
}

class _ReorderableTreeNodeTileState extends State<ReorderableTreeNodeTile> {
  late final _dragHandleKey = GlobalKey();

  bool _isDragging = false;

  void onDragStarted() {
    setState(() {
      _isDragging = true;
    });
  }

  void onDragEnd(DraggableDetails details) {
    _isDragging = false;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TreeNodeContent(
      node: widget.node,
      onFolderPressed: widget.onFolderPressed,
      leading: TreeDraggable<ExampleNode>(
        key: _dragHandleKey,
        node: widget.node,
        expandOnDragEnd: false,
        feedback: DragFeedback(node: widget.node),
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd,
        child: const Icon(Icons.drag_handle),
      ),
    );

    return TreeDragTarget<ExampleNode>(
      node: widget.node,
      onReorder: widget.onReorder,
      builder: (
        BuildContext context,
        TreeReorderingDetails<ExampleNode>? details,
      ) {
        Widget child = content;

        if (details != null) {
          child = TreeNodeDropAreaFeedback(
            details: details,
            child: child,
          );
        }

        child = TreeIndentation(
          child: child,
        );

        if (_isDragging) {
          return IgnorePointer(
            child: Opacity(
              opacity: .5,
              child: child,
            ),
          );
        }

        return child;
      },
    );
  }
}

class TreeNodeDropAreaFeedback extends StatelessWidget {
  const TreeNodeDropAreaFeedback({
    super.key,
    required this.child,
    required this.details,
  });

  final Widget child;
  final TreeReorderingDetails<ExampleNode> details;

  @override
  Widget build(BuildContext context) {
    const BorderSide borderSide = BorderSide(color: Colors.grey, width: 2.5);

    // Opinionated values.
    final BoxBorder border = details.when(
      above: () => const Border(top: borderSide),
      inside: () {
        if (details.targetNode.parent?.parent == null) {
          return const Border.fromBorderSide(borderSide);
        }
        return const BorderDirectional(
          top: borderSide,
          bottom: borderSide,
          end: borderSide,
        );
      },
      below: () => const Border(bottom: borderSide),
    );

    return DecoratedBox(
      decoration: BoxDecoration(border: border),
      child: child,
    );
  }
}

class TreeNodeContent extends StatelessWidget {
  const TreeNodeContent({
    super.key,
    required this.node,
    this.leading,
    this.onFolderPressed,
  });

  final ExampleNode node;
  final VoidCallback? onFolderPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          if (leading != null) leading!,
          if (onFolderPressed != null)
            if (node.hasChildren)
              ExpandIcon(
                key: GlobalObjectKey(node.key),
                padding: EdgeInsets.zero,
                isExpanded: node.isExpanded,
                onPressed: (_) => onFolderPressed!(),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.article, size: 16),
              ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(node.label),
          ),
        ],
      ),
    );
  }
}

class DragFeedback extends StatelessWidget {
  const DragFeedback({super.key, required this.node});

  final ExampleNode node;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
            child: TreeNodeContent(node: node),
          ),
        ),
      ),
    );
  }
}
