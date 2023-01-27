import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';

class SettingsCategories extends StatelessWidget {
  const SettingsCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final indentType = context.select<SettingsController, IndentType>(
      (controller) => controller.state.indentType,
    );

    return ListView(
      children: [
        const ColorSelector(),
        const Divider(height: 1),
        const Direction(),
        const Divider(height: 1),
        const AnimateExpansions(),
        const Divider(height: 1),
        const RootLevel(),
        const Divider(height: 1),
        const Indent(),
        const Divider(height: 1),
        const IndentGuideType(),
        const Divider(height: 1),
        if (indentType != IndentType.blank) ...[
          if (indentType == IndentType.connectingLines) ...[
            const RoundedConnections(),
            const Divider(height: 1),
          ],
          const LineThickness(),
          const Divider(height: 1),
          const LineOrigin(),
          const Divider(height: 1),
        ],
        const RestoreAllSettings(),
      ],
    );
  }
}

// Dark Mode -------------------------------------------------------------------

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = context.select<SettingsController, Brightness>(
      (controller) => controller.state.brightness,
    );

    final Brightness oppositeBrightness;
    final Widget icon;
    final String tooltip;

    if (brightness == Brightness.light) {
      oppositeBrightness = Brightness.dark;
      icon = const Icon(Icons.dark_mode_outlined);
      tooltip = 'Dark Mode';
    } else {
      oppositeBrightness = Brightness.light;
      icon = const Icon(Icons.light_mode_outlined);
      tooltip = 'Light Mode';
    }

    return IconButton(
      icon: icon,
      iconSize: 20,
      tooltip: tooltip,
      onPressed: () => context
          .read<SettingsController>()
          .updateBrightness(oppositeBrightness),
    );
  }
}

//* Animate Expand & Collapse --------------------------------------------------

class AnimateExpansions extends StatelessWidget {
  const AnimateExpansions({super.key});

  @override
  Widget build(BuildContext context) {
    final animatedExpansions = context.select<SettingsController, bool>(
      (controller) => controller.state.animateExpansions,
    );

    return SwitchListTile(
      title: const Text('Animate Expand & Collapse'),
      value: animatedExpansions,
      onChanged: (value) {
        context.read<SettingsController>().updateAnimateExpansions(value);
      },
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
    );
  }
}

//* Theme Color ----------------------------------------------------------------

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedColor = context.select<SettingsController, Color>(
      (controller) => controller.state.color,
    );

    return ExpansionTile(
      title: const Text('Theme Color'),
      trailing: ColorOption(color: selectedColor, canTap: false),
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const <Color>[Colors.black, Colors.white]
              .followedBy(Colors.primaries.reversed)
              .followedBy(Colors.accents)
              .map(ColorOption.fromColor)
              .toList(growable: false),
        ),
      ],
    );
  }
}

class ColorOption extends StatelessWidget {
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
  Widget build(BuildContext context) {
    void updateColor() => context.read<SettingsController>().updateColor(color);

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

//* Indent ---------------------------------------------------------------------

class Indent extends StatelessWidget {
  const Indent({super.key});

  @override
  Widget build(BuildContext context) {
    final indent = context.select<SettingsController, double>(
      (controller) => controller.state.indent,
    );

    return _SliderListTile(
      title: 'Indent per Level',
      value: indent,
      min: 0.0,
      max: 64.0,
      onChanged: (value) => context
          .read<SettingsController>()
          .updateIndent(value.roundToDouble()),
    );
  }
}

//* Indent Guide Type ----------------------------------------------------------

class IndentGuideType extends StatelessWidget {
  const IndentGuideType({super.key});

  @override
  Widget build(BuildContext context) {
    final indentType = context.select<SettingsController, IndentType>(
      (controller) => controller.state.indentType,
    );

    return ExpansionTile(
      title: const Text('Indent Guide Type'),
      subtitle: Text(
        indentType.title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      children: [
        for (final type in IndentType.allExcept(indentType))
          ListTile(
            title: Text(type.title),
            onTap: () {
              context.read<SettingsController>().updateIndentType(type);
            },
            dense: true,
          ),
      ],
    );
  }
}

//* Line Thickness -------------------------------------------------------------

class LineThickness extends StatelessWidget {
  const LineThickness({super.key});

  @override
  Widget build(BuildContext context) {
    final thickness = context.select<SettingsController, double>(
      (controller) => controller.state.lineThickness,
    );

    return _SliderListTile(
      title: 'Line Thickness',
      value: thickness,
      min: 0.0,
      max: 8.0,
      divisions: 16,
      onChanged: (value) {
        context.read<SettingsController>().updateLineThickness(value);
      },
    );
  }
}

//* Line Origin ----------------------------------------------------------------

class LineOrigin extends StatelessWidget {
  const LineOrigin({super.key});

  @override
  Widget build(BuildContext context) {
    final origin = context.select<SettingsController, double>(
      (controller) => controller.state.lineOrigin,
    );

    return _SliderListTile(
      title: 'Line Origin',
      value: origin,
      min: 0.0,
      max: 1.0,
      divisions: 10,
      onChanged: (value) {
        context.read<SettingsController>().updateLineOrigin(value);
      },
    );
  }
}

//* Root level -----------------------------------------------------------------

class RootLevel extends StatelessWidget {
  const RootLevel({super.key});

  @override
  Widget build(BuildContext context) {
    final rootLevel = context.select<SettingsController, int>(
      (controller) => controller.state.rootLevel,
    );

    return ListTile(
      title: const Text('Root Level'),
      trailing: Text(
        '$rootLevel',
        style: DefaultTextStyle.of(context).style.apply(
              color: Theme.of(context).colorScheme.primary,
              fontWeightDelta: 1,
              fontSizeDelta: 4,
            ),
      ),
      onTap: () => context
          .read<SettingsController>()
          .updateRootLevel(rootLevel == 0 ? 1 : 0),
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 24),
    );
  }
}

//* Rounded Line Connections ---------------------------------------------------

class RoundedConnections extends StatelessWidget {
  const RoundedConnections({super.key});

  @override
  Widget build(BuildContext context) {
    final roundedConnections = context.select<SettingsController, bool>(
      (controller) => controller.state.roundedCorners,
    );

    return SwitchListTile(
      title: const Text('Rounded Line Connections'),
      value: roundedConnections,
      onChanged: (value) {
        context.read<SettingsController>().updateRoundedCorners(value);
      },
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
    );
  }
}

//* Text Direction -------------------------------------------------------------

class Direction extends StatelessWidget {
  const Direction({super.key});

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).colorScheme.primary;

    final textDirection = context.select<SettingsController, TextDirection>(
      (controller) => controller.state.textDirection,
    );

    final String title;
    final TextDirection oppositeTextDirection;

    switch (textDirection) {
      case TextDirection.ltr:
        title = 'Left to Right';
        oppositeTextDirection = TextDirection.rtl;
        break;
      case TextDirection.rtl:
        title = 'Right to Left';
        oppositeTextDirection = TextDirection.ltr;
        break;
    }

    return ListTile(
      title: const Text('Text Direction'),
      subtitle: Text(
        title,
        style: TextStyle(color: highlightColor),
      ),
      onTap: () => context
          .read<SettingsController>()
          .updateTextDirection(oppositeTextDirection),
      trailing: const Icon(Icons.swap_horiz),
      iconColor: highlightColor,
    );
  }
}

//* Restore All Settings -------------------------------------------------------

class RestoreAllSettings extends StatelessWidget {
  const RestoreAllSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: const Text('Restore All Settings'),
      onTap: () => context.read<SettingsController>().restoreAll(),
      trailing: const Icon(Icons.restore),
      tileColor: colorScheme.errorContainer,
      textColor: colorScheme.onErrorContainer,
      iconColor: colorScheme.onErrorContainer,
    );
  }
}

// Other -----------------------------------------------------------------------

class _SliderListTile extends StatelessWidget {
  const _SliderListTile({
    required this.value,
    required this.title,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
  });

  final double value;
  final String title;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    final label = value.toString();

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('$title ($label)'),
      ),
      contentPadding: const EdgeInsets.only(top: 8),
      subtitle: Slider(
        min: min,
        max: max,
        value: value,
        label: label,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
