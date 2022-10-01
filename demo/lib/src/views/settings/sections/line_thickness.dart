import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class LineThickness extends ConsumerWidget {
  const LineThickness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double thickness = ref.watch(lineThicknessProvider);

    return Section(
      title: 'Line Thickness ($thickness)',
      child: Slider(
        min: 0.0,
        max: 8.0,
        divisions: 16,
        value: thickness,
        label: thickness.toString(),
        onChanged: (newValue) {
          ref.read(lineThicknessProvider.state).state = newValue;
        },
      ),
    );
  }
}
