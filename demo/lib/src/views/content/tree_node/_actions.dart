part of 'tile.dart';

class NodeActions extends ConsumerWidget {
  const NodeActions({
    super.key,
    required this.node,
    this.actionsMenyKey,
  });

  final DemoNode node;
  final GlobalKey<PopupMenuButtonState>? actionsMenyKey;

  void showCreateNodeModal(BuildContext context, WidgetRef ref) async {
    final DemoNode? child = await CreateNodeView.show(
      context,
      ref.read(screenProvider),
    );

    if (child == null) return;

    node.addChild(child);

    if (node.isExpanded) {
      ref.read(treeControllerProvider).rebuild();
    } else {
      ref.read(treeControllerProvider).expand(node);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      key: actionsMenyKey,
      tooltip: 'Show Actions',
      offset: const Offset(0, 20),
      color: colorScheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(6)),
      ),
      itemBuilder: (_) {
        if (node.parent == DemoNode.virtualRoot) {
          return _rootPopupItems;
        }
        return _nodePopupItems;
      },
      onSelected: (int selected) {
        if (selected == 0) {
          showCreateNodeModal(context, ref);
        } else {
          node.delete(recursive: selected == 2);
          ref.read(treeControllerProvider).rebuild();
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

const _rootPopupItems = <PopupMenuEntry<int>>[
  PopupMenuItem(
    value: 0,
    child: ListTile(
      dense: true,
      horizontalTitleGap: 8,
      title: Text('Add child'),
      subtitle: Text('Opens dialog to add a child'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.add_circle_rounded, color: Colors.green),
    ),
  ),
];

const _nodePopupItems = <PopupMenuEntry<int>>[
  ..._rootPopupItems,
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 1,
    child: ListTile(
      dense: true,
      horizontalTitleGap: 8,
      title: Text('Delete this node only'),
      subtitle: Text('Moves each child one level up'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_rounded, color: Colors.orange),
    ),
  ),
  PopupMenuDivider(height: 1),
  PopupMenuItem(
    value: 2,
    child: ListTile(
      dense: true,
      horizontalTitleGap: 8,
      title: Text('Delete entire subtree'),
      subtitle: Text('Descendants are deleted too'),
      contentPadding: EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(Icons.delete_forever_rounded, color: Colors.red),
    ),
  ),
];
