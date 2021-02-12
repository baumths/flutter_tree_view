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
  TreeViewTheme treeTheme = TreeViewTheme(
    nodeSelectedTileColor: Colors.grey.shade300,
  );

  @override
  void initState() {
    final rootNode = generateTreeNodes(sampleData);
    treeController = TreeViewController(rootNode: rootNode);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // TODO: Make a better example UI.

  @override
  Widget build(BuildContext context) {
    const iconColor = Colors.blue;
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
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, right: 8),
                      child: node.hasChildren
                          ? const Icon(Icons.folder, color: iconColor)
                          : const Icon(Icons.article, color: iconColor),
                    ),
                    Flexible(child: Text(node.data as String)),
                  ],
                ),
                onTap: () => showSnackBar(context, 'Node Tapped: ${node.data}'),
                onLongPress: () => setState(node.disable),
                trailing: [
                  IconButton(
                    icon: Icon(
                      Icons.star,
                      color: node.isSelected ? iconColor : Colors.grey,
                    ),
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
      appBar: AppBar(
        title: const Text('TreeView Example'),
        leading: IconButton(
          icon: const Icon(Icons.expand),
          onPressed: () async {
            setState(() {
              treeController.selectSubtree(treeController.find(2));
            });
            // final node = treeController.find(21112);
            // if (node != null) {
            //   treeController.expandNode(node);
            //   setState(() {
            //     node.select();
            //   });
            //   await Future.delayed(const Duration(seconds: 3));
            //   setState(() {
            //     node.deselect();
            //   });
            // }
          },
        ),
      ),
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
