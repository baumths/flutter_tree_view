import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings.dart';
import '../../providers/tree.dart';
import 'demo_item.dart';

final _highlightProvider = StateProvider<DemoNode?>((ref) => null);

class DemoTreeView extends ConsumerWidget {
  const DemoTreeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(treeControllerProvider);

    return TreeNavigation<DemoNode>(
      controller: controller,
      currentHighlight: ref.watch(_highlightProvider),
      onHighlightChanged: (DemoNode? node) {
        ref.read(_highlightProvider.state).state = node;
      },
      child: DefaultIndentGuide(
        guide: ref.watch(indentGuideProvider),
        child: TreeView<DemoNode>(
          controller: controller,
          padding: const EdgeInsets.all(8).copyWith(bottom: 80),
          itemBuilder: (_, TreeEntry<DemoNode> entry) {
            return DemoItem(node: entry.node);
          },
        ),
      ),
    );
  }
}
