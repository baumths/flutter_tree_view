part of 'settings_view.dart';

class _LineColorSelector extends StatelessWidget {
  const _LineColorSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = AppController.of(context);

    return ValueListenableBuilder<TreeViewTheme>(
      valueListenable: appController.treeViewTheme,
      builder: (_, TreeViewTheme theme, __) {
        return _SettingsButtonBar(
          label: 'Line Color',
          buttonBarPadding: const EdgeInsets.symmetric(horizontal: 24),
          children: colorOptions.map((color) {
            return _ColoredCircle(
              color: color,
              isSelected: theme.lineColor == color,
              onColorChanged: (color) {
                if (color == theme.lineColor) return;
                appController.updateTheme(theme.copyWith(lineColor: color));
              },
            );
          }).toList(growable: false),
        );
      },
    );
  }

  static const colorOptions = <Color>[
    Colors.grey, // TreeViewTheme Default
    Color(0xFFE53935), // Colors.red.shade600
    Color(0xFF43A047), // Colors.green.shade600
    kDarkBlue, // Colors.blue.shade800
    // Colors.purple.shade600
  ];
}

class _ColoredCircle extends StatefulWidget {
  const _ColoredCircle({
    Key? key,
    required this.color,
    required this.onColorChanged,
    this.isSelected = false,
  }) : super(key: key);

  final Color color;
  final bool isSelected;

  final ValueChanged<Color> onColorChanged;

  @override
  State<_ColoredCircle> createState() => _ColoredCircleState();
}

class _ColoredCircleState extends State<_ColoredCircle> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: (isHovering) => setState(() => _isHovering = isHovering),
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      onTap: () => widget.onColorChanged(widget.color),
      child: AnimatedContainer(
        duration: kAnimationDuration,
        curve: Curves.ease,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: _isHovering ? Colors.black87 : Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: widget.isSelected
                  ? const Icon(Icons.check_rounded, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
