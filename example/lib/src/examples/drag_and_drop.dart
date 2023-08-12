import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../shared.dart' show watchAnimationDurationSetting;

//! Disclaimer: This example is very opinionated, it may not work for your usecase.

class Node {
  Node({
    required this.id,
    Iterable<Node>? children,
  }) : _children = <Node>[] {
    if (children == null) return;

    for (final Node child in children) {
      child._parent = this;
      _children.add(child);
    }
  }

  final int id;
  final List<Node> _children;

  Iterable<Node> get children => _children;
  bool get isLeaf => _children.isEmpty;

  Node? get parent => _parent;
  Node? _parent;

  int get index => _parent?._children.indexOf(this) ?? -1;

  void insertChild(int index, Node node) {
    // Adjust the index if necessary when dropping a node at the same parent
    if (node._parent == this && node.index < index) {
      index--;
    }

    // Ensure the node is removed from its previous parent and update it
    node
      .._parent?._children.remove(node)
      .._parent = this;

    _children.insert(index, node);
  }
}

extension on TreeDragAndDropDetails<Node> {
  /// Splits the target node's height in three and checks the vertical offset
  /// of the dragging node, applying the appropriate callback.
  T mapDropPosition<T>({
    required T Function() whenAbove,
    required T Function() whenInside,
    required T Function() whenBelow,
  }) {
    final double oneThirdOfTotalHeight = targetBounds.height * 0.3;
    final double pointerVerticalOffset = dropPosition.dy;

    if (pointerVerticalOffset < oneThirdOfTotalHeight) {
      return whenAbove();
    } else if (pointerVerticalOffset < oneThirdOfTotalHeight * 2) {
      return whenInside();
    } else {
      return whenBelow();
    }
  }
}

class DragAndDropTreeView extends StatefulWidget {
  const DragAndDropTreeView({super.key});

  @override
  State<DragAndDropTreeView> createState() => _DragAndDropTreeViewState();
}

class _DragAndDropTreeViewState extends State<DragAndDropTreeView> {
  late final Node root;
  late final TreeController<Node> treeController;

  @override
  void initState() {
    super.initState();
    root = Node(id: -1);
    populateExampleTree(root);

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,

      // The parentProvider is extremely important when automatically expanding
      // and collapsing tree nodes on hover, as the [TreeDragTarget] needs to
      // ensure that it doesn't collapse an ancestor of the dragging node as it
      // would be removed from the view stopping the drag updates and callbacks.
      //
      // When not provided, the [TreeController] would need to first locate the
      // target node in the tree and then check its ancestors, which could be
      // very expensive for deep trees.
      parentProvider: (Node node) => node.parent,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  void onNodeAccepted(TreeDragAndDropDetails<Node> details) {
    Node? newParent;
    int newIndex = 0;

    details.mapDropPosition(
      whenAbove: () {
        // Insert the dragged node as the previous sibling of the target node.
        newParent = details.targetNode.parent;
        newIndex = details.targetNode.index;
      },
      whenInside: () {
        // Insert the dragged node as the last child of the target node.
        newParent = details.targetNode;
        newIndex = details.targetNode.children.length;

        // Ensure that the dragged node is visible after reordering.
        treeController.setExpansionState(details.targetNode, true);
      },
      whenBelow: () {
        // Insert the dragged node as the next sibling of the target node.
        newParent = details.targetNode.parent;
        newIndex = details.targetNode.index + 1;
      },
    );

    (newParent ?? root).insertChild(newIndex, details.draggedNode);

    // Rebuild the tree to show the reordered node in its new vicinity.
    treeController.rebuild();
  }

  @override
  Widget build(BuildContext context) {
    final IndentGuide indentGuide = DefaultIndentGuide.of(context);
    final BorderSide borderSide = BorderSide(
      color: Theme.of(context).colorScheme.outline,
      width: indentGuide is AbstractLineGuide ? indentGuide.thickness : 2.0,
    );

    return AnimatedTreeView<Node>(
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
        return DragAndDropTreeTile(
          entry: entry,
          borderSide: borderSide,
          onNodeAccepted: onNodeAccepted,
          onFolderPressed: () => treeController.toggleExpansion(entry.node),
        );
      },
      duration: watchAnimationDurationSetting(context),
    );
  }
}

class DragAndDropTreeTile extends StatelessWidget {
  const DragAndDropTreeTile({
    super.key,
    required this.entry,
    required this.onNodeAccepted,
    this.borderSide = BorderSide.none,
    this.onFolderPressed,
  });

  final TreeEntry<Node> entry;
  final TreeDragTargetNodeAccepted<Node> onNodeAccepted;
  final BorderSide borderSide;
  final VoidCallback? onFolderPressed;

  @override
  Widget build(BuildContext context) {
    return TreeDragTarget<Node>(
      node: entry.node,
      onNodeAccepted: onNodeAccepted,
      builder: (BuildContext context, TreeDragAndDropDetails<Node>? details) {
        Decoration? decoration;

        if (details != null) {
          // Add a border to indicate which portion of the target's height the
          // dragging node will be inserted.
          decoration = BoxDecoration(
            border: details.mapDropPosition(
              whenAbove: () => Border(top: borderSide),
              whenInside: () => Border.fromBorderSide(borderSide),
              whenBelow: () => Border(bottom: borderSide),
            ),
          );
        }

        return TreeDraggable<Node>(
          node: entry.node,
          childWhenDragging: Opacity(
            opacity: .5,
            child: IgnorePointer(
              child: TreeTile(entry: entry),
            ),
          ),
          feedback: IntrinsicWidth(
            child: Material(
              elevation: 4,
              child: TreeTile(
                entry: entry,
                showIndentation: false,
                onFolderPressed: () {},
              ),
            ),
          ),
          child: TreeTile(
            entry: entry,
            onFolderPressed: entry.node.isLeaf ? null : onFolderPressed,
            decoration: decoration,
          ),
        );
      },
    );
  }
}

class TreeTile extends StatelessWidget {
  const TreeTile({
    super.key,
    required this.entry,
    this.onFolderPressed,
    this.decoration,
    this.showIndentation = true,
  });

  final TreeEntry<Node> entry;
  final VoidCallback? onFolderPressed;
  final Decoration? decoration;
  final bool showIndentation;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Row(
        children: [
          FolderButton(
            isOpen: entry.node.isLeaf ? null : entry.isExpanded,
            onPressed: onFolderPressed,
          ),
          Expanded(
            child: Text('Node ${entry.node.id}'),
          ),
        ],
      ),
    );

    if (decoration != null) {
      content = DecoratedBox(
        decoration: decoration!,
        child: content,
      );
    }

    if (showIndentation) {
      return TreeIndentation(
        entry: entry,
        child: content,
      );
    }

    return content;
  }
}

int _uniqueId = 0;
void populateExampleTree(
  Node node, [
  int level = 0,
  Random? rng,
  int minChildCount = 3,
]) {
  if (level >= 3) return;

  rng ??= Random();

  for (int index = 0; index <= minChildCount + rng.nextInt(3); ++index) {
    final child = Node(id: _uniqueId++).._parent = node;
    node._children.add(child);
    populateExampleTree(child, level + 1, rng, 1);
  }
}
