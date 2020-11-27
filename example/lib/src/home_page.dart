import 'package:flutter/material.dart';

import 'package:flutter_tree_view/flutter_tree_view.dart';

import 'map_hierarchical_data.dart';
import 'sample_data.dart';

part 'home_utils.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TreeViewController treeController;
  TreeViewTheme treeTheme = const TreeViewTheme();

  @override
  void initState() {
    final rootNode = generateTreeNodes(sampleData);
    treeController = TreeViewController(rootNode: rootNode);
    super.initState();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: TreeView(
            controller: treeController,
            theme: treeTheme,
            onTap: (n) => showSnackBar(context, 'Node Tapped: ${n.data}'),
            onLongPress: (n) {
              showSnackBar(context, 'Node Pressed: ${n.data}');
            },
            nodeBuilder: (_, TreeNode node) {
              return NodeWidget(node: node, treeController: treeController);
            },
          ),
        ),
      ),
      appBar: AppBar(title: const Text('TreeView Example')),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ToggleNodesFAB(controller: treeController),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: nextStyle,
            label: const Text('CHANGE STYLE'),
            icon: const Icon(Icons.refresh),
            backgroundColor: Colors.orange.shade900,
          ),
        ],
      ),
    );
  }

  void nextStyle() {
    setState(() {
      switch (treeTheme.lineStyle) {
        case LineStyle.disabled:
          treeTheme = treeTheme.copyWith(lineStyle: LineStyle.connected);
          showSnackBar(
            context,
            'Line Style: Connected',
            duration: const Duration(seconds: 3),
          );
          break;
        case LineStyle.connected:
          treeTheme = treeTheme.copyWith(lineStyle: LineStyle.scoped);
          showSnackBar(
            context,
            'Line Style: Scoped',
            duration: const Duration(seconds: 3),
          );
          break;
        case LineStyle.scoped:
          treeTheme = treeTheme.copyWith(lineStyle: LineStyle.disabled);
          showSnackBar(
            context,
            'Line Style: Disabled',
            duration: const Duration(seconds: 3),
          );
          break;
      }
    });
  }
}

class NodeWidget extends StatelessWidget {
  const NodeWidget({
    Key? key,
    required this.node,
    required this.treeController,
  }) : super(key: key);

  final TreeNode node;
  final TreeViewController treeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          node.hasChildren ? Icons.folder : Icons.article,
          color: Theme.of(context).accentColor,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Text(node.data as String),
        ),
        const Spacer(),
        if (node.hasChildren)
          ToggleNodeIconButton(
            node: node,
            controller: treeController,
            onToggle: (n) => showSnackBar(context, 'Node Toggled: ${n.data}'),
          ),
      ],
    );
  }
}
