import 'package:flutter/material.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

part 'home_utils.dart';

const kDarkBlue = Color(0xFF1565C0);

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.treeController}) : super(key: key);

  final TreeViewController treeController;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TreeViewController treeController;

  late var treeTheme = const TreeViewTheme();

  late Widget _nodeIcon = const NodeWidgetLeadingIcon();

  late final _altController = TreeViewController(
    rootNode: TreeNode(id: 'ALT 🌲️ ROOT')
      ..addChildren(
        [
          TreeNode(id: 'A', label: 'A')
            ..addChild(
              TreeNode(id: 'A 1', label: 'A 1'),
            ),
          TreeNode(id: 'B', label: 'B'),
          TreeNode(id: 'C', label: 'C')
            ..addChildren(
              [
                TreeNode(id: 'C1', label: 'C 1'),
                TreeNode(id: 'C2', label: 'C 2')
                  ..addChild(
                    TreeNode(id: 'C21', label: 'C 2 1'),
                  ),
                for (var index = 3; index < 11; index++)
                  TreeNode(id: 'C$index', label: 'C $index')
              ],
            ),
        ],
      ),
  );

  @override
  void initState() {
    super.initState();
    treeController = widget.treeController;
  }

  @override
  void dispose() {
    _altController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 600,
            child: TreeView(
              controller: treeController,
              theme: treeTheme,
              nodeHeight: 40.0,
              nodeBuilder: (_, treeNode) => NodeWidget(
                leading: _nodeIcon,
                onTap: () => showSnackBar(
                  context,
                  treeNode.toString(),
                  duration: const Duration(seconds: 3),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _SpeedDial(
        treeController: treeController,
        changeLineStyle: _changeLineStyle,
        changeNodeIcon: _changeNodeIcon,
        changeTreeController: _changeTreeController,
      ),
      appBar: AppBar(
        title: const Center(child: Text('TreeView Example')),
        actions: [
          IconButton(
            tooltip: 'REVEAL NODE',
            icon: const Icon(Icons.search_rounded),
            onPressed: _revealNodeDialog,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _changeTreeController() {
    if (treeController == widget.treeController) {
      setState(() {
        treeController = _altController;
      });
    } else {
      setState(() {
        treeController = widget.treeController;
      });
    }
  }

  void _revealNodeDialog() async {
    final nodeId = await showDialog<String>(
      context: context,
      builder: (context) => const Dialog(child: FindNodeDialog()),
    );
    if (nodeId == null) return;

    final node = treeController.find(nodeId);

    if (node != null) {
      treeController.expandUntil(node);
    } else {
      showSnackBar(context, "Couldn't find a TreeNode with ID = $nodeId");
    }
  }

  void _changeNodeIcon() {
    if (_nodeIcon is NodeWidgetLeadingIcon) {
      setState(() {
        _nodeIcon = const ExpandNodeIcon(
          color: kDarkBlue,
          disabledColor: Colors.grey,
        );
      });
    } else {
      setState(() {
        _nodeIcon = const NodeWidgetLeadingIcon();
      });
    }
  }

  void _changeLineStyle() {
    switch (treeTheme.lineStyle) {
      case LineStyle.disabled:
        setState(() {
          treeTheme = treeTheme.copyWith(lineStyle: LineStyle.connected);
        });
        break;
      case LineStyle.connected:
        setState(() {
          treeTheme = treeTheme.copyWith(lineStyle: LineStyle.scoped);
        });
        break;
      case LineStyle.scoped:
        setState(() {
          treeTheme = treeTheme.copyWith(lineStyle: LineStyle.disabled);
        });
        break;
    }
  }
}
