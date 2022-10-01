import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../example_node.dart';

class ReorderableTreeView extends StatefulWidget {
  const ReorderableTreeView({super.key});

  @override
  State<ReorderableTreeView> createState() => _ReorderableTreeViewState();
}

class _ReorderableTreeViewState extends State<ReorderableTreeView> {
  late final ExampleTree tree;
  late final TreeController<ExampleNode> treeController;

  @override
  void initState() {
    super.initState();

    tree = ExampleTree.createSampleTree();
    treeController = TreeController<ExampleNode>(tree: tree);
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
        newParent = details.targetNode.parent ?? tree.root;
        newIndex = newParent.children.indexOf(details.targetNode);
      },
      inside: () {
        // drop `details.draggedNode` as the last child of `details.targetNode`
        newParent = details.targetNode;
        newIndex = newParent.children.length;
      },
      below: () {
        // drop `details.draggedNode` as next sibling of `details.targetNode`
        newParent = details.targetNode.parent ?? tree.root;
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
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<ExampleNode>(
      controller: treeController,
      itemBuilder: (BuildContext context, TreeEntry<ExampleNode> entry) {
        final Widget content = Content(
          node: entry.node,
          onFolderPressed: () => treeController.toggleExpansion(entry.node),
        );

        return ReorderableTreeItem<ExampleNode>(
          treeEntry: entry,
          onReorder: _onReorder,
          decorationBuilder: _decorationBuilder,
          feedback: Feedback(child: content),
          dragAnchorStrategy: pointerDragAnchorStrategy,
          childWhenDragging: ChildWhenDragging(entry: entry, child: content),
          mouseCursor: SystemMouseCursors.grab,
          child: content,
        );
      },
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
    return Row(
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
    );
  }
}

class Feedback extends StatelessWidget {
  const Feedback({super.key, required this.child});

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
              blurRadius: 20,
              blurStyle: BlurStyle.outer,
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
  const ChildWhenDragging({
    super.key,
    required this.child,
    required this.entry,
  });

  final TreeEntry<ExampleNode> entry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Opacity(
        opacity: 0.6,
        child: TreeItem(
          treeEntry: entry,
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
extension<T extends Object> on TreeReorderingDetails<T> {
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