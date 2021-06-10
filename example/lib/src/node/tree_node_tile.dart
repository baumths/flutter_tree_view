import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../common/common.dart';
import '../app_controller.dart';

part '_actions_chip.dart';
part '_selector.dart';
part '_title.dart';

const Color _kDarkBlue = Color(0xFF1565C0);

const RoundedRectangleBorder kRoundedRectangleBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

class TreeNodeTile extends StatefulWidget {
  const TreeNodeTile({Key? key}) : super(key: key);

  @override
  _TreeNodeTileState createState() => _TreeNodeTileState();
}

class _TreeNodeTileState extends State<TreeNodeTile> {
  @override
  Widget build(BuildContext context) {
    final appController = AppController.of(context);
    final nodeScope = TreeNodeScope.of(context);

    return InkWell(
      onTap: () => _describeAncestors(nodeScope.node),
      onLongPress: () => appController.toggleSelection(nodeScope.node.id),
      child: ValueListenableBuilder<ExpansionButtonType>(
        valueListenable: appController.expansionButtonType,
        builder: (context, ExpansionButtonType buttonType, __) {
          return Row(
            children: buttonType == ExpansionButtonType.folderFile
                ? const [
                    LinesWidget(),
                    NodeWidgetLeadingIcon(useFoldersOnly: true),
                    _NodeActionsChip(),
                    _NodeSelector(),
                    SizedBox(width: 8),
                    Expanded(child: _NodeTitle()),
                  ]
                : const [
                    LinesWidget(),
                    SizedBox(width: 4),
                    _NodeActionsChip(),
                    _NodeSelector(),
                    SizedBox(width: 8),
                    Expanded(child: _NodeTitle()),
                    ExpandNodeIcon(expandedColor: _kDarkBlue),
                  ],
          );
        },
      ),
    );
  }

  void _describeAncestors(TreeNode node) {
    final ancestors = node.ancestors.map((ancestor) => ancestor.id).join('/');

    showSnackBar(
      context,
      'Path of "${node.label}": /$ancestors/${node.id}',
      duration: const Duration(seconds: 3),
    );
  }
}
