import 'package:flutter/material.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'src/pages.dart';

// Check out the Live Demo:
// - https://mbaumgartenbr.github.io/flutter_tree_view

// `ExampleApp` was moved down below to avoid obstructing this example.
void main() => runApp(const ExampleApp());

// Create a "Tree Node" model implementing the [TreeNode] contract.
class MyNode extends TreeNode<MyNode> {
  MyNode({
    required this.label,

    // if defined as `this.children = const []` we wouldn't be able to modify
    // the children list later.
    List<MyNode>? children,
  }) : children = children ?? <MyNode>[];

  // Add any additional properties to your tree nodes.
  final String label;

  @override
  final List<MyNode> children;
}

// Create a `StatefulWidget` to hold your tree nodes.
class SimpleTreeView extends StatefulWidget with PageInfo {
  const SimpleTreeView({super.key});

  @override
  String get title => 'Simple TreeView';

  @override
  State<SimpleTreeView> createState() => _SimpleTreeViewState();
}

class _SimpleTreeViewState extends State<SimpleTreeView> {
  // An indexing node that will hold the roots of the tree as its children.
  // This node is not displayed on the tree in this example.
  late final MyNode root;

  @override
  void initState() {
    super.initState();

    // Create/Fetch your hierarchical data
    root = MyNode(
      label: '/',
      children: <MyNode>[
        MyNode(
          label: 'Root 1',
          children: [
            MyNode(
              label: 'Node 1.A',
              children: [
                MyNode(label: 'Node 1.A.1'),
                MyNode(label: 'Node 1.A.2'),
              ],
            ),
            MyNode(label: 'Node 1.B'),
          ],
        ),
        MyNode(
          label: 'Root 2',
          children: [
            MyNode(
              label: 'Node 2.A',
              children: [
                MyNode(
                  label: 'Node 2.A.1',
                  children: List.generate(
                    5,
                    (int index) => MyNode(label: 'Node 2.A.1.${index + 1}'),
                  ),
                ),
                MyNode(label: 'Node 2.A.2'),
              ],
            ),
            MyNode(label: 'Node 2.B')
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<MyNode>(
      roots: root.children,
      // Provide a widget builder callback to map your tree nodes into widgets.
      itemBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
        // [TreeNode]s are wrapped in [TreeEntry]s when the [SliverTree] is
        // flattening the tree. [TreeEntry]s hold important info about the node
        // it holds relative to the tree, like the index, parent, level, etc...
        //
        // The [TreeIndentation] uses those values to properly indent your nodes
        // (and paint lines for, if enabled).
        //
        // [TreeEntry]s are short lived, each time [TreeController.rebuild] is
        // called, a new [TreeEntry] is created for each node so the data it
        // holds is always up to date.
        final MyNode node = entry.node;

        // [TreeItem] has some basic functionality and is not required, any
        // widget can be used. If using a custom widget, take a look at
        // [TreeIndentation] to make sure your nodes are indented correclty.
        return TreeItem(
          // Add a callback to "toggle" the expansion state of the node, the
          // [TreeItem] doesn't do it by itself, this way you could opt to use
          // a leading/trailing button instead.

          onTap: () {
            // As an alternative to the following, use a [TreeController] with
            // `treeController.toggleExpansion(node)`.
            SliverTree.of<MyNode>(context).toggleExpansion(node);
          },
          onLongPress: () {
            final TreeController<MyNode> treeController =
                SliverTree.of<MyNode>(context).controller;

            if (entry.isExpanded) {
              treeController.collapseCascading(node);
            } else {
              treeController.expandCascading(node);
            }
          },
          // Provide an indent guide if desired. Indent guides can be used to
          // add decorations to the indentation of tree nodes.
          // This could also be provided through a [DefaultTreeIndentGuide]
          // above the [TreeView].
          indentGuide: const IndentGuide.blank(),
          // The widget to show to the side of [TreeIndentation]'s indent and
          // lines. The internal [TreeIndentation] respects the text direction
          // of `Directionality.maybeOf(context)` and defaults to left-to-right.
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Show a simple arrow to indicate the expansion state of this
                // node. See also: [FolderButton] and [ExpandIcon].
                entry.isExpanded
                    ? const Icon(Icons.arrow_drop_down)
                    : const Icon(Icons.arrow_right),
                const SizedBox(width: 8),
                Text(node.label),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePages(
        pages: [
          SimpleTreeView(),
          LazyTreeView(),
          NavigableTreeView(),
          ReorderableTreeView(),
        ],
      ),
    );
  }
}
