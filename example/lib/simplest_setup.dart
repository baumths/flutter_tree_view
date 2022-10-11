import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class Node extends TreeNode<Node> {
  Node({
    required this.label,
    List<Node>? children,
    super.isExpanded,
  })  : id = Object(),
        children = children ?? <Node>[];

  final String label;

  @override
  final Object id;

  @override
  final List<Node> children;
}

class SimpleTree extends StatefulWidget {
  const SimpleTree({super.key});

  @override
  State<SimpleTree> createState() => _SimpleTreeState();
}

class _SimpleTreeState extends State<SimpleTree> {
  late final TreeController<Node> treeController;

  @override
  void initState() {
    super.initState();

    final Node root = Node(
      label: 'Sections',
      isExpanded: true,
      children: [
        Node(
          label: 'Section A',
          children: [
            Node(label: 'Sub-Section'),
          ],
        ),
        Node(
          label: 'Section B',
          children: [
            Node(label: 'Sub-Section 001'),
            Node(label: 'Sub-Section 002'),
          ],
        ),
        Node(
          label: 'Section C',
          children: [
            Node(label: 'Sub-Section I'),
            Node(label: 'Sub-Section II'),
            Node(label: 'Sub-Section III'),
          ],
        ),
      ],
    );

    treeController = TreeController<Node>(root: root);
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<Node>(
      controller: treeController,
      itemBuilder: (BuildContext context, TreeEntry<Node> entry) {
        return TreeItem(
          onTap: () => treeController.toggleExpansion(entry.node),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(entry.node.label),
          ),
        );
      },
    );
  }
}
