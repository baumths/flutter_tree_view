import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class RootLevel extends ConsumerWidget {
  const RootLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Section(
      child: ListTile(
        title: const Text('Root Level'),
        style: ListTileStyle.drawer,
        trailing: Material(
          color: colorScheme.primaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Consumer(builder: (_, ref, __) {
              final rootLevel = ref.watch(rootLevelProvider);

              return Text(
                '$rootLevel',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              );
            }),
          ),
        ),
        onTap: () => ref
            .read(rootLevelProvider.state)
            .update((state) => state == 0 ? 1 : 0),
      ),
    );
  }
}
