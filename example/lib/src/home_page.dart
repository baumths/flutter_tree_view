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
  static const double nodeHeight = 48.0;

  late ScrollController scrollController;

  late TreeViewController treeController;

  late var treeTheme = const TreeViewTheme();

  late Widget _nodeIcon = const NodeWidgetLeadingIcon(
    useFoldersOnly: true,
    leafIconDisabledColor: kDarkBlue,
  );

  late final _dynamicController = TreeViewController(
    onAboutToExpand: (TreeNode nodeAboutToExpand) {
      if (treeController != _dynamicController) return;

      final children = _dynamicChildrenMap[nodeAboutToExpand.id];

      if (children != null) {
        nodeAboutToExpand.addChildren(
          children.map((child) => TreeNode(id: child, label: child)),
        );
      }
    },
    rootNode: TreeNode(id: 'Root')
      //? Initial Dynamic Nodes
      ..addChild(TreeNode(id: 'A', label: 'A'))
      ..addChild(TreeNode(id: 'B', label: 'B'))
      ..addChild(TreeNode(id: 'C', label: 'C')),
  );

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    treeController = widget.treeController;
  }

  @override
  void dispose() {
    _dynamicController.dispose();
    scrollController.dispose();
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
                  nodeHeight: nodeHeight,
                  controller: treeController,
                  scrollController: scrollController,
                  theme: treeTheme,
                  nodeBuilder: (_, TreeNode treeNode) => NodeWidget(
                    leading: _nodeIcon,
                    onLongPress: () => _describeAncestors(treeNode),
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
        controller: treeController,
        changeLineStyle: _changeLineStyle,
        changeNodeIcon: _changeNodeIcon,
        changeTreeController: _changeController,
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

  void _changeController() {
    if (treeController == widget.treeController) {
      setState(() {
        treeTheme = treeTheme.copyWith(roundLineCorners: true);
        treeController = _dynamicController;
      });
    } else {
      setState(() {
        treeTheme = treeTheme.copyWith(roundLineCorners: false);
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

      final offsetOfNode = treeController.indexOf(node) * nodeHeight;

      await scrollController.animateTo(
        offsetOfNode,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
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
        treeTheme = treeTheme.copyWith(lineThickness: value);
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

  void _describeAncestors(TreeNode node) {
    final ancestors = node.ancestors.map((e) => e.id).join('/');

    showSnackBar(
      context,
      'Path of "${node.label}": /$ancestors/${node.id}',
      duration: const Duration(seconds: 3),
    );
  }
}

const _dynamicChildrenMap = <String, List<String>>{
  'A': ['A1'],
  'C': ['C1', 'C2', 'C3', 'C4', 'C5'],
  'C2': ['C21'],
  'C4': ['C41', 'C42'],
  'C41': ['C411'],
};
