import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class RoundedConnections extends ConsumerWidget {
  const RoundedConnections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final bool roundedConnections = ref.watch(roundedCornersProvider);

    return Section(
      child: SwitchListTile(
        title: Text(
          'Rounded Line Connections',
          style: DefaultTextStyle.of(context).style,
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        value: roundedConnections,
        activeColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary.withOpacity(.3),
        onChanged: (newValue) {
          ref.read(roundedCornersProvider.state).state = newValue;
        },
      ),
    );
  }
}
