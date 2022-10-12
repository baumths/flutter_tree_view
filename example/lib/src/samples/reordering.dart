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

class _ReorderableTreeViewState extends State<ReorderableTreeView> {
  late final TreeController<ExampleNode> treeController;

  @override
  void initState() {
    super.initState();

    treeController = TreeController<ExampleNode>(
      root: ExampleNode.createSampleTree(),
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  Widget _decorationBuilder(
    BuildContext context,
    Widget child,
    TreeReorderingDetails<ExampleNode> details,
  ) {
    const BorderSide borderSide = BorderSide(color: Colors.grey, width: 2.5);

    // Opinionated values.
    // `when` is defined as an extension at the end of this file.
    final Border border = details.when<Border>(
      above: () => const Border(top: borderSide),
      inside: () => const Border.fromBorderSide(borderSide),
      below: () => const Border(bottom: borderSide),
    );

    return DecoratedBox(
      decoration: BoxDecoration(border: border),
      child: child,
    );
  }

  void _onReorder(TreeReorderingDetails<ExampleNode> details) {
    late final ExampleNode newParent;
    late int newIndex;

    // Opinionated values.
    // `when` is defined as an extension at the end of this file.
    details.when<void>(
      above: () {
        // drop `details.draggedNode` as previous sibling of `details.targetNode`
        newParent = details.targetNode.parent ?? treeController.root;
        newIndex = newParent.children.indexOf(details.targetNode);
      },
      inside: () {
        // drop `details.draggedNode` as the last child of `details.targetNode`
        newParent = details.targetNode;
        newIndex = newParent.children.length;
      },
      below: () {
        // drop `details.draggedNode` as next sibling of `details.targetNode`
        newParent = details.targetNode.parent ?? treeController.root;
        newIndex = newParent.children.indexOf(details.targetNode) + 1;
      },
    );

    // Take a look at [ExampleNode.insertChild] which handles reparenting and
    // index clashes.
    newParent.insertChild(newIndex, details.draggedNode);

    if (!newParent.isExpanded) {
      // expand the new parent to show the reordered node at the new location.
      // Not calling [TreeController.expand] because this changed will be
      // picked up by the following call to [TreeController.rebuild].
      newParent.isExpanded = true;
    }

    // Rebuild the flattened tree to make sure the changes are shown.
    treeController.rebuild();
    briefHighlight(details.draggedNode.id);
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<ExampleNode>(
      controller: treeController,
      itemBuilder: (BuildContext context, TreeEntry<ExampleNode> entry) {
        Widget content = Content(
          node: entry.node,
          onFolderPressed: () => treeController.toggleExpansion(entry.node),
        );

        if (highlightedId == entry.node.id) {
          content = HighlightShadow(child: content);
        }

        return ReorderableTreeItem<ExampleNode>(
          node: entry.node,
          onReorder: _onReorder,
          decorationBuilder: _decorationBuilder,
          feedback: HighlightShadow(child: content),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          childWhenDragging: ChildWhenDragging(child: content),
          mouseCursor: SystemMouseCursors.grab,
          child: content,
        );
      },
    );
  }

  // opinionated way of highlighting a node after been reordered
  Timer? highlightTimer;
  int? highlightedId;

  void briefHighlight(int id) {
    highlightTimer?.cancel();

    setState(() {
      highlightedId = id;
    });

    highlightTimer = Timer(
      const Duration(seconds: 2),
      () => setState(() => highlightedId = null),
    );
  }
}

class Content extends StatelessWidget {
  const Content({
    super.key,
    required this.node,
    this.onFolderPressed,
  });

  final ExampleNode node;
  final VoidCallback? onFolderPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          if (node.children.isEmpty)
            const IconButton(
              onPressed: null,
              icon: Icon(Icons.article),
            )
          else
            FolderButton(
              isOpen: node.isExpanded,
              onPressed: onFolderPressed,
            ),
          Expanded(
            child: Text(node.label),
          ),
        ],
      ),
    );
  }
}

class HighlightShadow extends StatelessWidget {
  const HighlightShadow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ChildWhenDragging extends StatelessWidget {
  const ChildWhenDragging({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Opacity(
        opacity: 0.6,
        child: TreeItem(
          child: child,
        ),
      ),
    );
  }
}

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
      // top segment, could reorder as parent or previous sibling
      return above();
    } else if (y <= heightFactor * 2) {
      // center segment, could reorder to first or last of new siblings
      return inside();
    } else {
      // bottom segment, could reorder as first child or next sibling
      return below();
    }
  }
}
