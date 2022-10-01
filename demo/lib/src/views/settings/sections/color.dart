import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Section(
      title: 'Color',
      child: Consumer(builder: (_, ref, __) {
        final color = ref.watch(colorProvider);

        return ExpansionTile(
          title: ColorOption(color: color, canTap: false),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          expandedAlignment: Alignment.centerLeft,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.start,
              children: Colors.primaries
                  .cast<Color>()
                  .followedBy(Colors.accents)
                  .followedBy(const [Colors.white, Colors.black])
                  .map(ColorOption.fromColor)
                  .toList(),
            ),
          ],
        );
      }),
    );
  }
}

class ColorOption extends ConsumerWidget {
  const ColorOption({
    super.key,
    required this.color,
    this.canTap = true,
  });

  factory ColorOption.fromColor(Color color) => ColorOption(color: color);

  final Color color;
  final bool canTap;

  static const borderRadius = BorderRadius.all(Radius.circular(4));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void updateColor() => ref.read(colorProvider.state).state = color;

    return Material(
      color: color,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: canTap ? updateColor : null,
        child: const SizedBox.square(dimension: 20),
      ),
    );
  }
}
