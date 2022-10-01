import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class LineOrigin extends ConsumerWidget {
  const LineOrigin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double origin = ref.watch(lineOriginProvider);

    return Section(
      title: 'Line Origin ($origin)',
      child: Slider(
        min: 0.0,
        max: 1.0,
        divisions: 10,
        value: origin,
        label: origin.toString(),
        onChanged: (newValue) {
          ref.read(lineOriginProvider.state).state = newValue;
        },
      ),
    );
  }
}
