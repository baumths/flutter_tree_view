import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class Node {
  Node({
    required this.id,
    Iterable<Node>? children,
  }) : _children = <Node>[...?children] {
    for (final Node child in _children) {
      child._parent = this;
    }
  }

  final int id;
  final List<Node> _children;
  Iterable<Node> get children => _children;

  Node? get parent => _parent;
  Node? _parent;

  int get index => parent?._children.indexOf(this) ?? -1;

  void addChild(Node node) {
    node
      .._parent?._children.remove(node)
      .._parent = this;
    _children.add(node);
  }

  void insertChild(int index, Node node) {
    if (node.parent == this && node.index < index) {
      --index;
    }

    node
      .._parent?._children.remove(node)
      .._parent = this;

    _children.insert(index, node);
  }

  @override
  String toString() => 'Node $id';
}

class ReorderingTreeView extends StatefulWidget {
  const ReorderingTreeView({super.key});

  @override
  State<ReorderingTreeView> createState() => _ReorderingTreeViewState();
}

class _ReorderingTreeViewState extends State<ReorderingTreeView> {
  late final Node root = Node(id: 0);
  late final TreeController<Node> treeController;

  @override
  void initState() {
    super.initState();
    populateTree(root);
    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverReorderableTree<Node>(
          controller: treeController,
          nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
            return TreeTile(
              entry: entry,
              onFolderPressed: () => treeController.toggleExpansion(entry.node),
            );
          },
          proxyDecorator: (
            Widget child,
            TreeEntry<Node> entry,
            Animation<double> animation,
          ) {
            final double t = Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(0, 4, t)!;

            return Material(
              elevation: elevation,
              child: child,
            );
          },
        ),
      ],
    );
  }
}

class TreeTile extends StatelessWidget {
  const TreeTile({
    super.key,
    required this.entry,
    this.onFolderPressed,
  });

  final TreeEntry<Node> entry;
  final VoidCallback? onFolderPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TreeReorderableDragStartListener(
          index: entry.index,
          child: const Icon(Icons.drag_indicator),
        ),
        Expanded(
          child: TreeIndentation(
            entry: entry,
            child: Row(
              children: [
                FolderButton(
                  isOpen: entry.hasChildren ? entry.isExpanded : null,
                  onPressed: onFolderPressed,
                ),
                Flexible(
                  child: Text(entry.node.toString()),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

int _uniqueId = 1;
populateTree(Node node, [int level = 0]) {
  if (level > 5) return;

  for (int index = 0; index < 3; ++index) {
    final Node child = Node(id: _uniqueId++);
    node.addChild(child);
    populateTree(child, level + 1);
  }
}
