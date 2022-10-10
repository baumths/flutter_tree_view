import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Section(
          title: 'Color',
          child: Consumer(
            builder: (_, ref, child) {
              final selectedColor = ref.watch(colorProvider);

              return ExpansionTile(
                title: ColorOption(color: selectedColor, canTap: false),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                expandedAlignment: Alignment.centerLeft,
                children: [child!],
              );
            },
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.start,
              children: ColorOption.all,
            ),
          ),
        ),
        Positioned.directional(
          end: 18,
          top: 6,
          textDirection: Directionality.of(context),
          child: const DarkModeButton(),
        ),
      ],
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

  static final List<Widget> all = Colors.primaries
      .cast<Color>()
      .followedBy(Colors.accents)
      .followedBy(const [Colors.white, Colors.black])
      .map(ColorOption.fromColor)
      .toList();

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

class DarkModeButton extends ConsumerWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.watch(brightnessProvider);

    final Brightness oppositeBrightness;
    final Widget icon;

    if (brightness == Brightness.light) {
      oppositeBrightness = Brightness.dark;
      icon = const Icon(Icons.light_mode_outlined);
    } else {
      oppositeBrightness = Brightness.light;
      icon = const Icon(Icons.dark_mode_outlined);
    }

    return IconButton(
      icon: icon,
      iconSize: 20,
      onPressed: () {
        ref.read(brightnessProvider.state).state = oppositeBrightness;
      },
    );
  }
}
