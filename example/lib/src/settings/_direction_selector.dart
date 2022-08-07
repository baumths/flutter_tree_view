part of 'settings_view.dart';

class _DirectionSelector extends StatelessWidget {
  const _DirectionSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = AppController.of(context);

    return ValueListenableBuilder<TreeViewTheme>(
      valueListenable: appController.treeViewTheme,
      builder: (_, TreeViewTheme theme, __) {
        final selectedDirection = theme.direction;

        void changeDirection(TextDirection direction) {
          if (direction == selectedDirection) return;
          appController.updateTheme(
            theme.copyWith(direction: direction),
          );
        }

        return _SettingsButtonBar(
          label: 'Direction',
          buttonBarPadding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            TextButton(
              onPressed: () => changeDirection(TextDirection.ltr),
              child: Text(
                'Left to Right',
                style: TextStyle(
                  color: selectedDirection == TextDirection.ltr
                      ? kDarkBlue
                      : Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => changeDirection(TextDirection.rtl),
              child: Text(
                'Right to Left',
                style: TextStyle(
                  color: selectedDirection == TextDirection.rtl
                      ? kDarkBlue
                      : Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
