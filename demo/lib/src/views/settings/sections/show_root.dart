import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class ShowRoot extends ConsumerWidget {
  const ShowRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final showRoot = ref.watch(showRootProvider);

    return Section(
      child: SwitchListTile(
        title: Text(
          'Show Root Node',
          style: DefaultTextStyle.of(context).style,
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        value: showRoot,
        activeColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary.withOpacity(.3),
        onChanged: (newValue) {
          ref.read(showRootProvider.state).state = newValue;
        },
      ),
    );
  }
}
