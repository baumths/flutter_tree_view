part of 'settings_view.dart';

class _ToggleRoundedCornersButton extends StatelessWidget {
  const _ToggleRoundedCornersButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = AppController.of(context);
    return ValueListenableBuilder<TreeViewTheme>(
      valueListenable: appController.treeViewTheme,
      builder: (_, theme, child) {
        return SwitchListTile(
          title: const Text(
            'Rounded Corners',
            style: TextStyle(
              color: kDarkBlue,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 24),
          activeColor: kDarkBlue,
          tileColor: const Color(0x331565c0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          value: theme.roundLineCorners,
          onChanged: (bool value) {
            final oldValue = theme.roundLineCorners;

            if (oldValue == value) return;

            appController.updateTheme(
              appController.treeViewTheme.value
                  .copyWith(roundLineCorners: value),
            );
          },
        );
      },
    );
  }
}
