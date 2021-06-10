part of 'settings_view.dart';

class _LineStyleSelector extends StatelessWidget {
  const _LineStyleSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = AppController.of(context);

    return ValueListenableBuilder<TreeViewTheme>(
      valueListenable: appController.treeViewTheme,
      builder: (_, TreeViewTheme theme, __) {
        final selectedLineStyle = theme.lineStyle;

        void changeLineStyle(LineStyle style) {
          if (style == selectedLineStyle) return;
          appController.updateTheme(
            theme.copyWith(lineStyle: style),
          );
        }

        return _SettingsButtonBar(
          label: 'Line Style',
          buttonBarPadding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            TextButton(
              onPressed: () => changeLineStyle(LineStyle.connected),
              child: Text(
                'Connected',
                style: TextStyle(
                  color: selectedLineStyle == LineStyle.connected
                      ? kDarkBlue
                      : Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => changeLineStyle(LineStyle.scoped),
              child: Text(
                'Scoped',
                style: TextStyle(
                  color: selectedLineStyle == LineStyle.scoped
                      ? kDarkBlue
                      : Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => changeLineStyle(LineStyle.disabled),
              child: Text(
                'Disabled',
                style: TextStyle(
                  color: selectedLineStyle == LineStyle.disabled
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
