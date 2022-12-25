import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/responsive.dart';
import '../../../tree.dart';
import '../create_node_view.dart';

part '_actions.dart';
part '_content.dart';
part '_reordering.dart';
part '_scope.dart';

class NodeTile extends StatefulWidget {
  const NodeTile({super.key});

  @override
  State<NodeTile> createState() => _NodeTileState();
}

class _NodeTileState extends State<NodeTile> {
  late DemoNode node;
  late TreeController<DemoNode> treeController;

  final _actionsMenuKey = GlobalKey<PopupMenuButtonState>();
  late final focusNode = FocusNode();

  void showActionsMenu() {
    _actionsMenuKey.currentState?.showButtonMenu();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    node = NodeScope.of(context);
    treeController = SliverTree.of<DemoNode>(context).controller;
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NodeTileReordering(
      builder: (Widget child) {
        return TreeItem(
          focusNode: focusNode,
          focusColor: Colors.transparent,
          // onFocusChange: onFocusChange,
          borderRadius: BorderRadius.circular(6),
          mouseCursor: SystemMouseCursors.grab,
          onTap: () {
            // TODO:
          },
          onLongPress: showActionsMenu,
          child: child,
        );
      },
      child: NodeContent(
        actionsMenuKey: _actionsMenuKey,
        onHighlighted: () {
          if (focusNode.hasFocus) return;
          focusNode.requestFocus();
        },
      ),
    );
  }
}

extension on TreeReorderingDetails<DemoNode> {
  R when<R>({
    required R Function() above,
    required R Function() inside,
    required R Function() below,
  }) {
    final double y = dropPosition.dy;
    final double heightFactor = targetBounds.height / 3;

    if (y <= heightFactor) {
      return above();
    } else if (y <= heightFactor * 2) {
      return inside();
    } else {
      return below();
    }
  }
}
