import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/responsive.dart';
import '../../providers/tree.dart';
import 'create_node_view.dart';
import 'tree_view.dart';

final showTreeProvider = StateProvider<bool>((ref) => false);

class ContentView extends ConsumerWidget {
  const ContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTree = ref.watch(showTreeProvider);

    if (showTree) {
      return const DemoTreeView();
    }

    return const EmptyView();
  }
}

class EmptyView extends ConsumerWidget {
  const EmptyView({super.key});

  Future<void> createNodePressed(
    BuildContext context,
    WidgetRef ref, [
    DemoNode? parent,
  ]) async {
    final DemoNode? newNode = await CreateNodeView.show(
      context,
      ref.read(screenProvider),
    );

    if (newNode == null) return;

    late final root = ref.read(treeControllerProvider).root;

    (parent ?? root).addChild(newNode);

    showTree(ref);
  }

  void populateSampleTreePressed(WidgetRef ref) {
    DemoNode.populateDefaultTree();
    showTree(ref);
  }

  void showTree(WidgetRef ref) => ref
    ..read(treeControllerProvider).rebuild()
    ..read(showTreeProvider.state).state = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: SizedBox(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => populateSampleTreePressed(ref),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
              ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
              child: const Text('Populate Sample Tree'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => createNodePressed(context, ref),
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                backgroundColor: theme.colorScheme.secondaryContainer,
              ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
              child: const Text('Create Node'),
            ),
          ],
        ),
      ),
    );
  }
}
