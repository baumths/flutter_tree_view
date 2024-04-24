import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';

import '../examples.dart';
import '../shared.dart' show IndentGuideType, LineStyle;
import 'controller.dart';

class SettingsCategories extends StatelessWidget {
  const SettingsCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indentGuideType = context.select<SettingsController, IndentGuideType>(
      (controller) => controller.state.indentGuideType,
    );

    return ListTileTheme(
      data: theme.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        titleTextStyle: theme.textTheme.bodyMedium,
        subtitleTextStyle: theme.textTheme.bodyMedium!.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      child: ListView(
        children: [
          const TreeViewExampleSelector(),
          const TextDirectionalitySwitch(),
          const AnimatedExpansionSwitch(),
          const IndentSlider(),
          const IndentGuideTypeSelector(),
          if (indentGuideType != IndentGuideType.blank) ...[
            if (indentGuideType == IndentGuideType.connectingLines) ...[
              const RoundedConnectionsSwitch(),
              const ConnectBranchesSwitch(),
            ],
            const LineStyleSelector(),
            const LineThicknessSlider(),
            const LineOriginSlider(),
          ],
        ],
      ),
    );
  }
}

//* Dark Mode ------------------------------------------------------------------

class DarkModeButton extends StatelessWidget {
  const DarkModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedThemeMode = context.select<SettingsController, ThemeMode>(
      (controller) => controller.state.themeMode,
    );

    final (icon, tooltip, nextThemeMode) = switch (selectedThemeMode) {
      ThemeMode.system => (Icons.settings_brightness, 'Device', ThemeMode.dark),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Dark', ThemeMode.light),
      ThemeMode.light => (Icons.light_mode_outlined, 'Light', ThemeMode.system),
    };

    return IconButton(
      icon: Icon(icon),
      tooltip: '$tooltip Theme Mode',
      onPressed: () {
        context.read<SettingsController>().updateThemeMode(nextThemeMode);
      },
    );
  }
}

//* Theme Color ----------------------------------------------------------------

class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, __) => IconButton(
        onPressed: controller.toggle,
        tooltip: 'Theme Color',
        icon: IgnorePointer(
          child: ThemeColorOption(
            color: context.select<SettingsController, Color>(
              (controller) => controller.state.color,
            ),
          ),
        ),
      ),
      menuChildren: [
        SizedBox(
          width: 296,
          height: 136,
          child: GridView.extent(
            maxCrossAxisExtent: 24,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            physics: const NeverScrollableScrollPhysics(),
            children: const <Color>[Colors.black, Colors.white]
                .followedBy(Colors.primaries.reversed)
                .followedBy(Colors.accents)
                .map((color) => ThemeColorOption(color: color))
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class ThemeColorOption extends StatelessWidget {
  const ThemeColorOption({super.key, required this.color});

  final Color color;

  static const borderRadius = BorderRadius.all(Radius.circular(4));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => context.read<SettingsController>().updateColor(color),
        child: const SizedBox.square(dimension: 20),
      ),
    );
  }
}

//* Example Selector -----------------------------------------------------------

class TreeViewExampleSelector extends StatelessWidget {
  const TreeViewExampleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return _MenuListTile<Example>(
      header: 'Selected Example',
      options: Example.values,
      selected: context.watch<SelectedExampleNotifier>().value,
      onSelect: (example) {
        context.read<SelectedExampleNotifier>().select(example);
        Navigator.maybePop(context); // remove modals if any
      },
      contentBuilder: (example) => (example.title, example.icon),
    );
  }
}

//* Animate Expand & Collapse --------------------------------------------------

class AnimatedExpansionSwitch extends StatelessWidget {
  const AnimatedExpansionSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Animated Expand/Collapse'),
      value: context.select<SettingsController, bool>(
        (controller) => controller.state.animateExpansions,
      ),
      onChanged: (value) {
        context.read<SettingsController>().updateAnimateExpansions(value);
      },
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
    );
  }
}

//* Indent ---------------------------------------------------------------------

class IndentSlider extends StatelessWidget {
  const IndentSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return _SliderListTile(
      min: 0.0,
      max: 64.0,
      title: 'Indent per Level',
      value: context.select<SettingsController, double>(
        (controller) => controller.state.indent,
      ),
      onChanged: (value) => context
          .read<SettingsController>()
          .updateIndent(value.roundToDouble()),
    );
  }
}

//* Indent Guide Type ----------------------------------------------------------

class IndentGuideTypeSelector extends StatelessWidget {
  const IndentGuideTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return _MenuListTile<IndentGuideType>(
      header: 'Indent Guide Type',
      options: IndentGuideType.values,
      selected: context.select<SettingsController, IndentGuideType>(
        (controller) => controller.state.indentGuideType,
      ),
      onSelect: (option) {
        context.read<SettingsController>().updateIndentGuideType(option);
      },
      contentBuilder: (indentGuideType) => (indentGuideType.title, null),
    );
  }
}

//* Line Thickness -------------------------------------------------------------

class LineThicknessSlider extends StatelessWidget {
  const LineThicknessSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return _SliderListTile(
      min: 0.0,
      max: 8.0,
      divisions: 16,
      title: 'Line Thickness',
      value: context.select<SettingsController, double>(
        (controller) => controller.state.lineThickness,
      ),
      onChanged: (value) {
        context.read<SettingsController>().updateLineThickness(value);
      },
    );
  }
}

//* Line Origin ----------------------------------------------------------------

class LineOriginSlider extends StatelessWidget {
  const LineOriginSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return _SliderListTile(
      min: 0.0,
      max: 1.0,
      divisions: 10,
      title: 'Line Origin',
      value: context.select<SettingsController, double>(
        (controller) => controller.state.lineOrigin,
      ),
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
    return _MenuListTile<LineStyle>(
      header: 'Line Style',
      options: LineStyle.values,
      selected: context.select<SettingsController, LineStyle>(
        (controller) => controller.state.lineStyle,
      ),
      onSelect: (lineStyle) {
        context.read<SettingsController>().updateLineStyle(lineStyle);
        Navigator.maybePop(context); // remove modals if any
      },
      contentBuilder: (style) => (style.title, _LineStyleIcon(style)),
    );
  }
}

class _LineStyleIcon extends StatelessWidget {
  const _LineStyleIcon(this.lineStyle);

  final LineStyle lineStyle;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final selectedLineStyle = context.select<SettingsController, LineStyle>(
      (controller) => controller.state.lineStyle,
    );

    return CustomPaint(
      painter: _LineStylePainter(
        lineStyle,
        lineStyle == selectedLineStyle ? color.withOpacity(.3) : color,
      ),
      child: const SizedBox.square(dimension: 24),
    );
  }
}

class _LineStylePainter extends CustomPainter {
  _LineStylePainter(this.lineStyle, this.color);

  final LineStyle lineStyle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
          const Radius.circular(4),
        ),
      );

    path = switch (lineStyle) {
      LineStyle.dashed => dashPath(path, dashArray: dashArrayOf(6, 2)),
      LineStyle.dotted => dashPath(path, dashArray: dashArrayOf(2, 2)),
      LineStyle.solid => path,
    };

    canvas.drawPath(path, paint);
  }

  CircularIntervalList<double> dashArrayOf(double width, double space) {
    return CircularIntervalList<double>([width, space]);
  }

  @override
  bool shouldRepaint(covariant _LineStylePainter oldDelegate) {
    return oldDelegate.lineStyle != lineStyle || oldDelegate.color != color;
  }
}

//* Rounded Line Connections ---------------------------------------------------

class RoundedConnectionsSwitch extends StatelessWidget {
  const RoundedConnectionsSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Rounded Line Connections'),
      value: context.select<SettingsController, bool>(
        (controller) => controller.state.roundedCorners,
      ),
      onChanged: (value) {
        context.read<SettingsController>().updateRoundedCorners(value);
      },
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
    );
  }
}

//* Connect Branches -----------------------------------------------------------

class ConnectBranchesSwitch extends StatelessWidget {
  const ConnectBranchesSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Connect Branches'),
      value: context.select<SettingsController, bool>(
        (controller) => controller.state.connectBranches,
      ),
      onChanged: (value) {
        context.read<SettingsController>().updateConnectBranches(value);
      },
      contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
    );
  }
}

//* Text Direction -------------------------------------------------------------

class TextDirectionalitySwitch extends StatelessWidget {
  const TextDirectionalitySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final textDirection = context.select<SettingsController, TextDirection>(
      (controller) => controller.state.textDirection,
    );

    final (title, oppositeTextDirection) = switch (textDirection) {
      TextDirection.ltr => ('Left to Right', TextDirection.rtl),
      TextDirection.rtl => ('Right to Left', TextDirection.ltr),
    };

    return ListTile(
      title: const Text('Text Direction'),
      subtitle: Text(title),
      trailing: const Icon(Icons.swap_horiz),
      onTap: () => context
          .read<SettingsController>()
          .updateTextDirection(oppositeTextDirection),
    );
  }
}

//* Reset Settings -------------------------------------------------------------

class ResetSettingsButton extends StatelessWidget {
  const ResetSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.restore),
      tooltip: 'Reset Settings',
      onPressed: () => context
        ..read<SelectedExampleNotifier>().reset()
        ..read<SettingsController>().reset(),
    );
  }
}

//* Helpers --------------------------------------------------------------------

extension on MenuController {
  void toggle() => isOpen ? close() : open();
}

class _MenuListTile<T> extends StatelessWidget {
  const _MenuListTile({
    required this.header,
    required this.selected,
    required this.options,
    required this.onSelect,
    required this.contentBuilder,
  });

  final String header;
  final List<T> options;
  final T selected;
  final ValueChanged<T> onSelect;
  final (String title, Widget? icon) Function(T) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: const MenuStyle(alignment: AlignmentDirectional.centerEnd),
      alignmentOffset: const Offset(2, 0),
      builder: (_, controller, __) {
        final (selectedTitle, _) = contentBuilder(selected);
        return ListTile(
          onTap: controller.toggle,
          title: Text(header),
          subtitle: Text(selectedTitle),
          trailing: const Icon(Icons.chevron_right),
        );
      },
      menuChildren: options.map((option) {
        final (title, icon) = contentBuilder(option);
        return MenuItemButton(
          onPressed: option == selected ? null : () => onSelect(option),
          leadingIcon: icon,
          child: Text(title),
        );
      }).toList(growable: false),
    );
  }
}

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
      contentPadding: const EdgeInsets.only(top: 12),
      minVerticalPadding: 0,
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
