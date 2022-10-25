import 'package:flutter/material.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'src/samples/lazy_loading.dart';
import 'src/samples/navigation.dart';
import 'src/samples/reordering.dart';
import 'src/pages.dart';

// Check out the Live Demo:
// - https://mbaumgartenbr.github.io/flutter_tree_view

void main() => runApp(const ExampleApp());

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

/// Create a "Tree Node" model implementing the [TreeNode] contract.
///
/// [ImplicitTreeNodeId] is used because it is not imortant to identify nodes in
/// this example. This mixin creates an ordinary [Object] for the id of a node.
class MyNode extends TreeNode<MyNode> with ImplicitTreeNodeId {
  MyNode({
    required this.label,
    this.children = const [],

    /// The expansion state of this node
    super.isExpanded,
  });

  /// The direct children of this node. Can be any [Iterable].
  @override
  final List<MyNode> children;

  /// Include any additional data that you may need to pass around.
  final String label;
}

class SimpleTreeView extends StatefulWidget with PageInfo {
  const SimpleTreeView({super.key});

  @override
  String get title => 'Simple TreeView';

  @override
  String? get description => null;

  @override
  State<SimpleTreeView> createState() => _SimpleTreeViewState();
}

class _SimpleTreeViewState extends State<SimpleTreeView> {
  late final TreeController<MyNode> treeController;

  @override
  void initState() {
    super.initState();

    // This "nested" approach could be represented differently depending on the
    // usecase or how your app retrieves data.
    final MyNode root = MyNode(
      label: '/',
      isExpanded: true,
      children: [
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
                for (int index = 1; index <= 5; index++)
                  MyNode(label: 'Node 2.A.$index'),
              ],
            ),
            MyNode(label: 'Node 2.B'),
            MyNode(
              label: 'Node 2.C',
              children: [
                for (int index = 1; index <= 5; index++)
                  MyNode(label: 'Node 2.C.$index'),
              ],
            ),
            MyNode(label: 'Node 2.D'),
          ],
        ),
        MyNode(label: 'Root 3'),
      ],
    );

    // Create a [TreeController] and provide it your root node.
    treeController = TreeController<MyNode>(roots: root.children);
  }

  @override
  void dispose() {
    // Make sure to dispose the [TreeController] when it is not needed anymore.
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<MyNode>(
      controller: treeController,
      itemBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
        // [TreeNode]s are wrapped in [TreeEntry]s when the [TreeController] is
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
            // Optional performance tip (not relevant for small trees)
            if (node.hasChildren) {
              treeController.toggleExpansion(node);
            } else {
              // Avoid reflattening the tree if its structure would not change
              // by only updating the state of the node when it has no children,
              // instead of using [TreeController] methods.
              setState(() {
                node.isExpanded = !node.isExpanded;
              });
            }
          },
          indentGuide: const BlankIndentGuide(),
          // The widget to show to the side of [TreeIndentation]'s indent and
          // lines. [TreeIndentation] respects the text direction of
          // `Directionality.maybeOf(context)` and defaults to left-to-right.
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Show a simple arrow to indicate the exapnsion state of this
                // node. See also: [FolderButton] and [ExpandIcon].
                node.isExpanded
                    ? const Icon(Icons.keyboard_arrow_down)
                    : const Icon(Icons.keyboard_arrow_right),
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
