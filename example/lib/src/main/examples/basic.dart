import 'dart:math' as math show pi;
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '_example.dart';

class Node {
  Node({required this.title, Iterable<Node>? children})
      : children = <Node>[...?children];

  final String title;
  final List<Node> children;
}

class BasicTreeView extends StatefulWidget with TreeViewExample {
  const BasicTreeView({super.key});

  @override
  String get title => 'Basic';

  @override
  Widget? get icon => Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: const Icon(Icons.clear_all),
      );

  @override
  State<BasicTreeView> createState() => _BasicTreeViewState();
}

class _BasicTreeViewState extends State<BasicTreeView> {
  late final TreeController<Node> treeController;
  late final Node root = Node(title: '/');

  @override
  void initState() {
    super.initState();
    populateExampleTree(root);

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
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
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
        return TreeIndentation(
          entry: entry,
          child: Row(
            children: [
              ExpandIcon(
                key: GlobalObjectKey(entry.node),
                isExpanded: entry.isExpanded,
                onPressed: (_) => treeController.toggleExpansion(entry.node),
              ),
              Flexible(
                child: Text(entry.node.title),
              ),
            ],
          ),
        );
      },
    );
  }
}

int _uniqueId = 0;
void populateExampleTree(Node node, [int level = 0]) {
  if (level >= 7) return;
  node.children.addAll([
    Node(title: 'Node ${_uniqueId++}'),
    Node(title: 'Node ${_uniqueId++}'),
  ]);
  for (final Node child in node.children) {
    populateExampleTree(child, level + 1);
  }
}
