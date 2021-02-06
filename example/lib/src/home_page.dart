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

  // TODO: Make a better example UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
          child: TreeView(
            controller: treeController,
            theme: treeTheme,
            nodeBuilder: (_, node) {
              return NodeWidget(
                node: node,
                theme: treeTheme,
                controller: treeController,
                title: Text(node.data as String),
                onTap: () => showSnackBar(context, 'Node Tapped: ${node.data}'),
                onLongPress: () => setState(node.disable),
                trailing: [
                  IconButton(
                    icon: const Icon(Icons.star),
                    tooltip: node.isSelected ? 'Deselect' : 'Select',
                    color:
                        node.isSelected ? Theme.of(context).accentColor : null,
                    onPressed: node.isEnabled
                        ? () => setState(node.toggleSelected)
                        : null,
                  ),
                ],
              );
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
