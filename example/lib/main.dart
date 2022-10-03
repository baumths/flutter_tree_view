import 'package:flutter/material.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

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
          NavigableTreeView(),
          ReorderableTreeView(),
        ],
      ),
    );
  }
}

/// Create a "Node" model to hold the state of your tree nodes.
class TreeNode {
  TreeNode({
    required this.label,
    this.children = const [],
  }) : id = Object();

  /// To make this example as simple as possible, a plain [Object] is used as
  /// the identifier of this "Node" structure, but in real apps you could use
  /// the unique identifier of your data, or an auto incremented integer.
  ///
  /// From [Object]'s documentation:
  /// [Object] instances have no meaningful state, and are only useful
  /// through their identity. An [Object] instance is equal to itself
  /// only.
  final Object id;

  final List<TreeNode> children;

  bool isExpanded = false;

  final String label;
}

/// Implement the [Tree] api that dynamically builds the tree hierarchy for the
/// [TreeView].
///
/// The [TreeController] will use [Tree.flatten] to create new [TreeEntry]
/// instances for each node of the tree. Those nodes are latter provided to
/// the "itemBuilder" widget builder of [SliverTree] and [TreeView].
///
/// [TreeEntry]s hold important information about the context of its node in the
/// current flattened tree. They are short lived, each call to [Tree.flatten]
/// creates a new [TreeEntry] for each node so that the tree widgets always work
/// with fresh information.
///
/// For the simplicity of this example, I chose the "nested" approach where each
/// [TreeNode] holds its child nodes.
///
/// You could also use the "Repository Pattern" and cache the nodes in a map,
/// injecting your repository into your [Tree] implementation.
///
/// Make sure all methods of this class are simple and synchronous as they may
/// be called a lot during tree flattening.
class ExampleTree extends Tree<TreeNode> {
  const ExampleTree({required this.roots});

  /// The roots of your tree don't have to be "final", if they could change,
  /// just update the value of this variable and call [TreeController.rebuild].
  /// For that, you could use a "copyWith" method or simply remove the final
  /// keyword and update the variable in place, the `TreeController.tree =`
  /// setter automatically rebuilds the flattened tree if the two instances of
  /// [Tree] are different.
  @override
  final List<TreeNode> roots;

  /// The `id` of a node is required and should be unique among other nodes.
  /// It is used to cache information of its node in a map (e.g. when animating
  /// the expansion state changes).
  @override
  Object getId(TreeNode node) => node.id;

  /// It's recommended that instead of fetching a node's children in
  /// [getChildren], do it on a button press or during another action,
  /// [getChildren] and [roots] should always be synchronous. If the
  /// children of a node wasn't fetched yet when calling [getChildren],
  /// return an empty list, fetch those nodes and then rebuild the tree
  /// (i.e. [TreeController.rebuild]).
  @override
  List<TreeNode> getChildren(TreeNode node) => node.children;

  /// The [Tree.flatten] will use this method to get the expansion state of your
  /// nodes and provide it to [TreeEntry.isExpanded].
  @override
  bool getExpansionState(TreeNode node) => node.isExpanded;

  /// If attaching a [ChangeNotifier] to a [Tree] implementation, do not call
  /// notifyListeners from this method, it should only be used to update the
  /// value of the expansion state of [node], without impacting anything.
  /// The [TreeController] does "batch" operations using this method before
  /// flattening the tree (e.g. [TreeController.expandCascading] and
  /// [TreeController.expandAll]).
  @override
  void setExpansionState(TreeNode node, bool expanded) {
    node.isExpanded = expanded;
  }
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
  late final TreeController<TreeNode> treeController;

  @override
  void initState() {
    super.initState();

    // This "nested" approach could be represented differently depending on the
    // usecase or how your app retrieves data.
    final List<TreeNode> roots = [
      TreeNode(
        label: 'Root 1',
        children: [
          TreeNode(
            label: 'Node 1.A',
            children: [
              TreeNode(label: 'Node 1.A.1'),
              TreeNode(label: 'Node 1.A.2'),
            ],
          ),
          TreeNode(label: 'Node 1.B'),
        ],
      ),
      TreeNode(
        label: 'Root 2',
        children: [
          TreeNode(
            label: 'Node 2.A',
            children: [
              for (int index = 1; index <= 5; index++)
                TreeNode(label: 'Node 2.A.$index'),
            ],
          ),
          TreeNode(label: 'Node 2.B'),
          TreeNode(
            label: 'Node 2.C',
            children: [
              for (int index = 1; index <= 5; index++)
                TreeNode(label: 'Node 2.C.$index'),
            ],
          ),
          TreeNode(label: 'Node 2.D'),
        ],
      ),
      TreeNode(label: 'Root 3'),
    ];

    // Create a [TreeController] and provide your [Tree] implementation to it.
    treeController = TreeController<TreeNode>(
      tree: ExampleTree(roots: roots),
    );
  }

  @override
  void dispose() {
    // Make sure to dispose the [TreeController] when it is not needed anymore.
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<TreeNode>(
      controller: treeController,
      itemBuilder: (BuildContext context, TreeEntry<TreeNode> entry) {
        // The [TreeNode] model is wrapped in [TreeEntry] when [Tree.flatten] is
        // called by [TreeController]. [TreeEntry]s hold important info about
        // the node it holds relative to the tree, like the index, parent,
        // level, expansion state, etc...
        // The [TreeIndentation] uses those values to properly indent your nodes
        // (and paint lines for, if enabled).
        //
        // [TreeEntry]s are short lived, each time [TreeController.rebuild] is
        // called, a new [TreeEntry] is created for each node so the data it
        // holds is always up to date.
        final TreeNode node = entry.node;

        // [TreeItem] has some basic functionality and is not required, any
        // widget can be used. If using a custom widget, take a look at
        // [TreeIndentation] to make sure your nodes are indented correclty.
        return TreeItem<TreeNode>(
          // The [TreeEntry] is required by the inner [TreeIndentation] to
          // correctly indent the node it holds (and paint lines, if enabled).
          treeEntry: entry,
          // Add a callback to "toggle" the expansion state of the node held by
          // this entry, the [TreeItem] doesn't do it by itself, this way you
          // could opt to use a leading/trailing button instead.
          onTap: () => treeController.toggleExpansion(node),
          indentGuide: const ConnectingLinesGuide(indent: 40),
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
