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
  late final TreeSelection<Node> treeSelection;

  @override
  void initState() {
    super.initState();

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
      parentProvider: (Node node) => node.parent,
      defaultExpansionState: true,
    );

    treeSelection = TreeSelection<Node>(
      childrenProvider: (Node node) => node.children,
      parentProvider: (Node node) => node.parent,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    treeSelection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<Node>(
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
        return TreeTile(
          entry: entry,
          onPressed: () => treeController.toggleExpansion(entry.node),
          leading: ListenableBuilder(
            listenable: treeSelection,
            builder: (context, child) => Checkbox(
              tristate: true,
              value: treeSelection.stateOf(entry.node),
              onChanged: (_) => treeSelection.toggle(entry.node),
            ),
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
    this.onPressed,
    this.leading,
  });

  final TreeEntry<Node> entry;
  final VoidCallback? onPressed;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: InkWell(
        onTap: onPressed,
        child: TreeIndentation(
          entry: entry,
          child: Row(
            children: [
              const SizedBox(width: 4),
              if (leading != null) leading!,
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
  }
}
