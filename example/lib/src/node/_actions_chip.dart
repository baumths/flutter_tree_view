part of 'tree_node_tile.dart';

class _NodeActionsChip extends StatefulWidget {
  const _NodeActionsChip({Key? key}) : super(key: key);

  @override
  State<_NodeActionsChip> createState() => _NodeActionsChipState();
}

class _NodeActionsChipState extends State<_NodeActionsChip> {
  final GlobalKey<PopupMenuButtonState> _popupMenuKey = GlobalKey();

  PopupMenuButtonState? get _menu => _popupMenuKey.currentState;

  @override
  Widget build(BuildContext context) {
    final nodeScope = TreeNodeScope.of(context);

    return PopupMenuButton<int>(
      key: _popupMenuKey,
      tooltip: 'Show Actions',
      offset: const Offset(0, 32),
      color: Colors.blueGrey.shade100,
      shape: kRoundedRectangleBorder,
      elevation: 6,
      itemBuilder: (_) => kPopupMenuItems,
      onSelected: (int selected) {
        if (selected == 0) {
          showAddNodeDialog(context, nodeScope.node);
        } else {
          _delete(context, deleteSubtree: selected == 2);
        }
      },
      child: RawChip(
        onPressed: () => _menu?.showButtonMenu(),
        backgroundColor: const Color(0x331565c0),
        label: Text(
          nodeScope.node.id,
          style: const TextStyle(
            color: _kDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        avatar: const Icon(
          Icons.settings_rounded,
          size: 20,
          color: _kDarkBlue,
        ),
      ),
    );
  }

  void _delete(
    BuildContext context, {
    required bool deleteSubtree,
  }) {
    final treeController = AppController.of(context).treeController;
    final treeNode = TreeNodeScope.of(context).node;
    final parent = treeNode.parent ?? treeController.rootNode;

    treeNode.delete(recursive: deleteSubtree);

    treeController.refreshNode(parent, keepExpandedNodes: true);
  }
}

const kPopupMenuItems = <PopupMenuEntry<int>>[
  PopupMenuItem(
    value: 0,
    height: 28,
    child: ListTile(
      dense: true,
      title: Text('Add child'),
      subtitle: Text('Opens dialog to add a child'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.add_circle_rounded, color: _kDarkBlue),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 1,
    height: 28,
    child: ListTile(
      dense: true,
      title: Text('Delete this node only'),
      subtitle: Text('Moves children one level up'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_rounded, color: Colors.deepOrange),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 2,
    height: 28,
    child: ListTile(
      dense: true,
      title: Text('Delete entire subtree'),
      subtitle: Text('Children gets deleted too'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_forever_rounded, color: Colors.red),
    ),
  ),
];
