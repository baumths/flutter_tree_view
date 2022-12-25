import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings.dart';
import '../../tree.dart';
import 'tree_node/tile.dart';

class NodeTreeView extends ConsumerWidget {
  const NodeTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(treeControllerProvider);

    return DefaultIndentGuide(
      guide: ref.watch(indentGuideProvider),
      child: TreeView<DemoNode>(
        roots: controller.roots,
        controller: controller,
        rootLevel: ref.watch(rootLevelProvider),
        animationDuration: ref.watch(animatedExpansionsProvider)
            ? const Duration(milliseconds: 300)
            : Duration.zero,
        padding: const EdgeInsets.all(8),
        itemBuilder: (_, TreeItemDetails<DemoNode> entry) {
          return NodeScope(
            node: entry.virtualRootDetails,
            child: const NodeTile(),
          );
        },
      ),
    );
  }
}
