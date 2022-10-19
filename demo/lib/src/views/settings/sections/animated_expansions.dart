import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class AnimatedExpansions extends ConsumerWidget {
  const AnimatedExpansions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool animatedExpansions = ref.watch(animatedExpansionsProvider);

    return Section(
      child: SwitchListTile(
        title: Text(
          'Animated Expand/Collapse',
          style: DefaultTextStyle.of(context).style,
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        value: animatedExpansions,
        activeColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary.withOpacity(.3),
        onChanged: (newValue) {
          ref.read(animatedExpansionsProvider.state).state = newValue;
        },
      ),
    );
  }
}
