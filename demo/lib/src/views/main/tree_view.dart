import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tree.dart';
import 'demo_item.dart';

class DemoTreeView extends ConsumerWidget {
  const DemoTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(treeControllerProvider);

    return TreeNavigation<DemoNode>(
      controller: controller,
      child: TreeView<DemoNode>(
        controller: controller,
        padding: const EdgeInsets.all(8),
        itemBuilder: (_, TreeEntry<DemoNode> entry) {
          return DemoItem(treeEntry: entry);
        },
      ),
    );
  }
}
