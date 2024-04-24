import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

final lorem = Faker().lorem;

class Node {
  Node([this.children = const []]) : title = lorem.sentence() {
    for (final child in children) {
      child.parent = this;
    }
  }

  final String title;
  final List<Node> children;
  Node? parent;
}

final root = Node([
  Node([
    Node([
      Node(),
      Node(),
    ]),
    Node(),
    Node(),
    Node(),
  ]),
  Node(),
]);

class SelectableTreeView extends StatefulWidget {
  const SelectableTreeView({super.key});

  @override
  State<SelectableTreeView> createState() => _SelectableTreeViewState();
}

class _SelectableTreeViewState extends State<SelectableTreeView> {
  late final TreeController<Node> treeController;

  @override
  void initState() {
    super.initState();

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
      parentProvider: (Node node) => node.parent,
      defaultExpansionState: true,
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
        return SizedBox(
          height: 40,
          child: InkWell(
            onTap: () => treeController.toggleExpansion(entry.node),
            child: TreeIndentation(
              entry: entry,
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  Checkbox(
                    tristate: true,
                    value: treeController.getSelectionState(entry.node),
                    onChanged: (_) {
                      setState(() {
                        treeController.toggleSelection(entry.node);
                      });
                    },
                  ),
                  if (entry.hasChildren)
                    entry.isExpanded
                        ? const Icon(Icons.expand_less)
                        : const Icon(Icons.expand_more),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(entry.node.title),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
