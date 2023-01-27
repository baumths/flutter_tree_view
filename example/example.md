Please, visit the [Live Demo App](https://baumths.github.io/flutter_tree_view)
to fiddle around with the features of this package.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

// Create an object to hold your tree hierarchy (optional, could be a Map or
// any other data structure).
class MyNode {
  const MyNode({
    required this.title,
    this.children = const <MyNode>[],
  });

  final String title;
  final List<MyNode> children;
}

class MyTreeView extends StatelessWidget {
  const MyTreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return TreeView<MyNode>(
      // Provide the root nodes that, along with `childrenProvider`, will
      // originate the flat representation of your hierarchical data.
      roots: const <MyNode>[
        MyNode(
          title: 'Root 1',
          children: <MyNode>[
            MyNode(
              title: 'Node 1.A',
              children: <MyNode>[
                MyNode(title: 'Node 1.A.1'),
                MyNode(title: 'Node 1.A.2'),
              ],
            ),
            MyNode(title: 'Node 1.B'),
          ],
        ),
        MyNode(
          title: 'Root 2',
          children: <MyNode>[
            MyNode(
              title: 'Node 2.A',
              children: <MyNode>[
                MyNode(title: 'Node 2.A.1'),
              ],
            ),
            MyNode(title: 'Node 2.B')
          ],
        ),
      ],
      // Provide a callback for the tree to get the children of a given node
      // when building the flat representation of your hierarchical data.
      // Avoid doing heavy computations in this method, it should only behave
      // like a getter.
      childrenProvider: (MyNode node) => node.children,
      // Provide a widget builder callback to map your tree nodes into widgets.
      //
      // Your tree nodes are wrapped in [TreeEntry]s when flattening the tree.
      // [TreeEntry]s hold important details about its node relative to the
      // tree, like: expansion state, level, index, parent, etc.
      //
      // [TreeEntry]s are short lived, each time [TreeController.rebuild] is
      // called, a new [TreeEntry] is created for each node so the details it
      // holds are always up to date.
      nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
        // Provide a widget to display your tree nodes in the tree view.
        //
        // Can be any widget, just make sure to include a [TreeIndentation]
        // within its widget subtree so that tree nodes are properly indented.
        return MyTreeTile(
          node: entry.node,
          isExpanded: entry.isExpanded,
          // Add a callback to "toggle" the expansion state of this node.
          onTap: () {
            // A [TreeController] could be used instead to update the expansion
            // state of tree nodes.
            SliverTree.of<MyNode>(context).toggleExpansion(entry.node);
          },
        );
      },
    );
  }
}

// Create a widget to display the data held by your tree nodes.
class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.node,
    required this.isExpanded,
    required this.onTap,
  });

  final MyNode node;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // Wrap your content in a [TreeIndentation] widget which will properly
      // indent your nodes (and paint guides, if enabled).
      //
      // If you don't want to display indent guides, you could replace this
      // [TreeIndentation] with a [Padding] widget, providing a padding of
      // `EdgeInsetsDirectional.only(start: TreeEntry.level * indentAmount)`
      child: TreeIndentation(
        // Provide an indent guide if desired. Indent guides can be used to
        // add decorations to the indentation of tree nodes.
        // This could also be provided through a [DefaultTreeIndentGuide]
        // above the [TreeView].
        guide: const IndentGuide.connectingLines(indent: 48),
        // The widget to render next to the indentation. [TreeIndentation]
        // respects the text direction of `Directionality.maybeOf(context)`
        // and defaults to left-to-right.
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              // Add a widget to indicate the expansion state of this node.
              // See also: [FolderButton].
              ExpandIcon(
                // A GlobalKey is needed for animations to work properly.
                key: GlobalObjectKey(node),
                isExpanded: isExpanded,
                onPressed: (_) => onTap(),
              ),
              Text(node.title),
            ],
          ),
        ),
      ),
    );
  }
}
```
