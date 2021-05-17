import 'package:flutter/material.dart';

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

part 'home_utils.dart';

const kDarkBlue = Color(0xFF1565C0);

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.rootNode}) : super(key: key);

  final TreeNode rootNode;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Used to toggle nodes from outside of the [TreeView]. Simply move this key
  /// to wherever you need to use it. Make sure you don't recreate the key, it
  /// could lead to State loss.
  late final _treeViewKey = GlobalKey<TreeViewState>();

  TreeViewState? get treeViewState => _treeViewKey.currentState;

  late TreeNode _rootNode;

  late var treeTheme = const TreeViewTheme();

  late Widget _nodeIcon = const NodeWidgetLeadingIcon(
    useFoldersOnly: true,
    leafIconDisabledColor: kDarkBlue,
  );

  late final _dynamicRootNode = TreeNode(id: 'DYNAMIC ROOT')
    //? Initial nodes
    ..addChild(TreeNode(id: 'A', label: 'A'))
    ..addChild(TreeNode(id: 'B', label: 'B'))
    ..addChild(TreeNode(id: 'C', label: 'C'));

  @override
  void initState() {
    super.initState();
    _rootNode = widget.rootNode;
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
                  key: _treeViewKey,
                  rootNode: _rootNode,
                  theme: treeTheme,
                  onAboutToExpand: _populateChildrenOfDynamicNode,
                  nodeBuilder: (_, TreeNode treeNode) => NodeWidget(
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
        treeViewKey: _treeViewKey,
        changeLineStyle: _changeLineStyle,
        changeNodeIcon: _changeNodeIcon,
        changeTreeController: _changeRootNode,
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

  void _populateChildrenOfDynamicNode(TreeNode node) {
    if (_rootNode != _dynamicRootNode) return;

    final children = _dynamicChildrenMap[node.id];

    if (children != null) {
      node.addChildren(
        children.map((child) => TreeNode(id: child, label: child)),
      );
    }
  }

  void _changeRootNode() {
    if (_rootNode == widget.rootNode) {
      setState(() {
        treeTheme = treeTheme.copyWith(roundLineCorners: true);
        _rootNode = _dynamicRootNode;
      });
    } else {
      setState(() {
        treeTheme = treeTheme.copyWith(roundLineCorners: false);
        _rootNode = widget.rootNode;
      });
    }
  }

  void _revealNodeDialog() async {
    final nodeId = await showDialog<String>(
      context: context,
      builder: (context) => const Dialog(child: FindNodeDialog()),
    );
    if (nodeId == null) return;

    final node = treeViewState?.find(nodeId);

    if (node != null) {
      treeViewState?.expandUntil(node);
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
}

const _dynamicChildrenMap = <String, List<String>>{
  'A': ['A1'],
  'C': ['C1', 'C2', 'C3', 'C4', 'C5'],
  'C2': ['C21'],
  'C4': ['C41', 'C42'],
  'C41': ['C411'],
};
