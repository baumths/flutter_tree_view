import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/tree_node.dart';

typedef Node = TreeNode<String>;

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
      data: 'Sections',
      isExpanded: true,
      children: [
        Node(
          data: 'Section A',
          children: [
            Node(data: 'Sub-Section'),
          ],
        ),
        Node(
          data: 'Section B',
          children: [
            Node(data: 'Sub-Section 001'),
            Node(data: 'Sub-Section 002'),
          ],
        ),
        Node(
          data: 'Section C',
          children: [
            Node(data: 'Sub-Section I'),
            Node(data: 'Sub-Section II'),
            Node(data: 'Sub-Section III'),
          ],
        ),
      ],
    );

    treeController = TreeController<Node>(
      tree: Node.createTree(
        roots: <Node>[root],
      ),
    );
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
        return TreeItem<Node>(
          treeEntry: entry,
          onTap: () => treeController.toggleExpansion(entry.node),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(entry.node.data ?? 'no data'),
          ),
        );
      },
    );
  }
}
