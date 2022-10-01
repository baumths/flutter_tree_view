import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/responsive.dart';
import 'create_node_view.dart';

void showCreateNodeForm(WidgetRef ref, BuildContext context) {
  final Screen screen = ref.read(screenProvider);

  screen.when(
    small: () {
      CreateNodeView.showBottomSheetForm<void>(context, null);
    },
    large: () {
      CreateNodeView.showDialogForm<void>(context, null);
    },
  );
}

class EmptyTree extends ConsumerWidget {
  const EmptyTree({super.key});

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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: theme.colorScheme.onPrimary,
                backgroundColor: theme.colorScheme.primary,
              ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
              child: const Text('Load Sample Tree'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => showCreateNodeForm(ref, context),
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
