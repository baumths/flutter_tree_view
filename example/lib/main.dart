import 'package:flutter/material.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'src/pages.dart';

// Check out the Live Demo:
// - https://mbaumgartenbr.github.io/flutter_tree_view

// `ExampleApp` was moved down below to avoid obstructing this example.
void main() => runApp(const ExampleApp());

/// Create a "Tree Node" model implementing the [TreeNode] contract.
class MyNode extends TreeNode<MyNode> {
  MyNode({
    required this.label,
    this.children = const [],
    this.isExpanded = false,
  });

  /// The unique identifier of this node, used by [SliverTreeState] to cache
  /// some values. If your implementation of [TreeNode] has complex `hashCode`
  /// and `operator ==`, consider overriding this property to provide a simpler
  /// identifier like [String], [int], [Key], etc...
  @override
  final Object id = Object();

  /// The direct children of this node. Can be any [Iterable].
  @override
  final List<MyNode> children;

  // Store the expansion state of this node.
  //
  // This way of storing the expansion state of tree nodes could be represented
  // differently if desired (e.g. using a `Set` to enable immutability).
  @override
  bool isExpanded;

  /// Include any additional data that you may need to pass around.
  final String label;
}

// Create a `StatefulWidget` to hold your tree nodes and controller.
class SimpleTreeView extends StatefulWidget with PageInfo {
  const SimpleTreeView({super.key});

  @override
  String get title => 'Simple TreeView';

  @override
  State<SimpleTreeView> createState() => _SimpleTreeViewState();
}

class _SimpleTreeViewState extends State<SimpleTreeView> {
  // This optional controller can be used to notify the [TreeView] that the
  // tree structure changed in some way so the [TreeView] can rebuild its
  // internal flat representation of the tree to show the new information.
  late final TreeController<MyNode> treeController;

  // The root nodes of your tree.
  late final List<MyNode> roots;

  @override
  void initState() {
    super.initState();

    // Create/Fetch your hierarchical data
    roots = <MyNode>[
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
    ];

    // Create a [TreeController] to dynamically manage the state of the tree
    // if desired.
    treeController = TreeController<MyNode>(
      // A callback that updates the expansion state of your nodes must be
      // provided. This callback is used internally by the package to update
      // the expansion state of nodes dynamically (e.g. when reordering, when
      // calling `TreeController.toggleExpansion()`, etc.).
      onExpansionChanged: (MyNode node, bool expanded) {
        // This way of updating the expansion state of tree nodes could be
        // represented differently if desired (e.g. using a `Set` to enable
        // immutability).
        node.isExpanded = expanded;
      },
    );
  }

  @override
  void dispose() {
    /// Don't forget to dispose your [TreeController].
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<MyNode>(
      // Provide the nodes that will be used to build the flat representation
      // of its hierarchy.
      roots: roots,
      // Provide the optional controller to update the tree dinamically.
      controller: treeController,
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

          // As an alternative for the following callback, if using a [TreeController]
          // with `onTap: () => treeController.toggleExpansion(node),` is enough.
          onTap: () {
            // Update the expansion state of your nodes directly and then
            // make sure to call `SliverTreeState.rebuild()` so that the
            // tree view can rebuild its flattened tree.
            node.isExpanded = !node.isExpanded;

            // If the toggled node has no children, the tree structure won't
            // change after a rebuild therefore a simple setState is enough.
            if (node.hasChildren) {
              SliverTree.of<MyNode>(context).rebuild();
            } else {
              setState(() {});
            }
          },
          // Provide an indent guide if desired. Indent guides can be used to
          // add decorations to the indentation of tree nodes.
          // This could be provided through a [DefaultTreeIndentGuide] above
          // the [TreeView].
          indentGuide: const IndentGuide.blank(),
          // The widget to show to the side of [TreeIndentation]'s indent and
          // lines. The internal [TreeIndentation] respects the text direction
          // of `Directionality.maybeOf(context)` and defaults to left-to-right.
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                /// Show a simple arrow to indicate the expansion state of this
                /// node. See also: [FolderButton] and [ExpandIcon].
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
