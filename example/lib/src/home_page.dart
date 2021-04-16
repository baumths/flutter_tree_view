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

  late Widget _nodeIcon = const NodeWidgetLeadingIcon(
    useFoldersOnly: true,
    leafIconDisabledColor: kDarkBlue,
  );

  static const _dynamicChildrenMap = <String, List<String>>{
    'A': ['A1'],
    'C': ['C1', 'C2', 'C3', 'C4', 'C5'],
    'C2': ['C21'],
    'C4': ['C41', 'C42'],
    'C41': ['C411'],
  };

  late final _dynamicController = TreeViewController(
    onAboutToExpand: (TreeNode nodeBeingExpanded) {
      final children = _dynamicChildrenMap[nodeBeingExpanded.id];

      if (children != null) {
        nodeBeingExpanded.addChildren(
          children.map((child) => TreeNode(id: child, label: child)),
        );
      }
    },
    rootNode: TreeNode(id: 'ROOT')
      ..addChildren(
        [
          //? Initial Nodes
          TreeNode(id: 'A', label: 'A'),
          TreeNode(id: 'B', label: 'B'),
          TreeNode(id: 'C', label: 'C'),
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
    _dynamicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
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
          Positioned(
            bottom: 24,
            right: 80,
            child: _LineThicknessSlider(
              onChanged: _lineThicknessChanged,
            ),
          )
        ],
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
        treeTheme = treeTheme.copyWith(
          roundLineCorners: true,
        );
        treeController = _dynamicController;
      });
    } else {
      setState(() {
        treeTheme = treeTheme.copyWith(
          roundLineCorners: false,
        );
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
        _nodeIcon = const NodeWidgetLeadingIcon(
          useFoldersOnly: true,
          leafIconDisabledColor: kDarkBlue,
        );
      });
    }
  }

  void _lineThicknessChanged(double value) {
    if (treeTheme.lineThickness != value) {
      setState(() {
        treeTheme = treeTheme.copyWith(
          lineThickness: value,
        );
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
