import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../examples.dart';
import 'controller.dart';

class SettingsCategories extends StatelessWidget {
  const SettingsCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final indentType = context.select<SettingsController, IndentType>(
      (controller) => controller.state.indentType,
    );

    final List<Widget> categories = [
      const ColorSelector(),
      const ExampleSelector(),
      const Direction(),
      const AnimateExpansions(),
      const Indent(),
      const IndentGuideType(),
      if (indentType != IndentType.blank) ...[
        if (indentType == IndentType.connectingLines) ...[
          const RoundedConnections(),
        ],
        const LineStyleSelector(),
        const LineThickness(),
        const LineOrigin(),
      ],
      const RestoreAllSettings(),
    ];

    return ListView.separated(
      itemCount: categories.length,
      itemBuilder: (_, int index) => categories[index],
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}

//* Dark Mode ------------------------------------------------------------------

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
      tooltip: tooltip,
      onPressed: () => context
          .read<SettingsController>()
          .updateBrightness(oppositeBrightness),
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
      childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        GridView.extent(
          shrinkWrap: true,
          maxCrossAxisExtent: 24,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
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
        child: const SizedBox.square(dimension: 24),
      ),
    );
  }
}

//* Example Selector =----------------------------------------------------------

class ExampleSelector extends StatelessWidget {
  const ExampleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notifier = context.watch<SelectedExampleNotifier>();
    final selectedExample = notifier.value;

    return ListTile(
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      iconColor: colorScheme.onSurface,
      title: const Text('Selected Example'),
      subtitle: Text(
        selectedExample.title,
        style: TextStyle(color: colorScheme.primary),
      ),
      trailing: ExamplesCatalog(
        selectedExample: selectedExample,
        onExampleSelected: notifier.select,
      ),
      onTap: ExamplesCatalog.showPopup,
    );
  }
}

class ExamplesCatalog extends StatelessWidget {
  const ExamplesCatalog({
    super.key,
    required this.onExampleSelected,
    required this.selectedExample,
  });

  final ValueChanged<Example?> onExampleSelected;
  final Example selectedExample;

  static final GlobalKey<PopupMenuButtonState> popupMenuKey = GlobalKey();
  static void showPopup() => popupMenuKey.currentState?.showButtonMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Example>(
      key: popupMenuKey,
      initialValue: selectedExample,
      onSelected: onExampleSelected,
      itemBuilder: (_) => <PopupMenuEntry<Example>>[
        for (final example in Example.values)
          PopupMenuItem(
            value: example,
            enabled: example != selectedExample,
            child: Row(
              children: [
                example.icon,
                const SizedBox(width: 16),
                Text(example.title),
              ],
            ),
          ),
      ],
      tooltip: 'Open Examples Popup',
      icon: const Icon(Icons.more_vert),
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

//* Line Style -----------------------------------------------------------------

class LineStyleSelector extends StatelessWidget {
  const LineStyleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedLineStyle = context.select<SettingsController, LineStyle>(
      (controller) => controller.state.lineStyle,
    );

    return ListTile(
      title: const Text('Line Style'),
      subtitle: Text(
        selectedLineStyle.title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      onTap: () async {
        final controller = context.read<SettingsController>();

        final RenderBox tile = context.findRenderObject()! as RenderBox;
        final Offset offset = tile.localToGlobal(Offset.zero);
        final Rect(:top, :right) = offset & tile.size;

        final LineStyle? newLineStyle = await showMenu<LineStyle>(
          context: context,
          position: RelativeRect.fromLTRB(right, top, tile.size.width, 0),
          items: <PopupMenuEntry<LineStyle>>[
            for (final LineStyle lineStyle in LineStyle.values)
              PopupMenuItem(
                value: lineStyle,
                enabled: lineStyle != selectedLineStyle,
                child: Text(lineStyle.title),
              ),
          ],
        );

        if (newLineStyle == null) return;
        controller.updateLineStyle(newLineStyle);
      },
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.restore),
        label: const Text('Restore Settings'),
        onPressed: () => context.read<SettingsController>().restoreAll(),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

//* Helpers --------------------------------------------------------------------

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
