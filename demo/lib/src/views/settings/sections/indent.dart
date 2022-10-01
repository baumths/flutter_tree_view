import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class Indent extends ConsumerWidget {
  const Indent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double indent = ref.watch(indentProvider);

    return Section(
      title: 'Indent per Level ($indent)',
      child: Slider(
        min: 0.0,
        max: 64.0,
        value: indent,
        label: indent.toString(),
        onChanged: (newValue) {
          ref.read(indentProvider.state).state = newValue.roundToDouble();
        },
      ),
    );
  }
}
