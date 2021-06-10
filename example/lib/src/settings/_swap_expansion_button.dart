part of 'settings_view.dart';

class _SwapExpansionButton extends StatelessWidget {
  const _SwapExpansionButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appController = AppController.of(context);

    return ValueListenableBuilder<ExpansionButtonType>(
      valueListenable: appController.expansionButtonType,
      builder: (_, ExpansionButtonType selectedType, Widget? child) {
        void changeButton(ExpansionButtonType newType) {
          if (newType == selectedType) return;
          appController.updateExpansionButton(newType);
        }

        final arrowColor = selectedType == ExpansionButtonType.chevron
            ? kDarkBlue
            : Colors.grey;

        final folderColor = selectedType == ExpansionButtonType.folderFile
            ? kDarkBlue
            : Colors.grey;

        return _SettingsButtonBar(
          label: 'Expansion Button Type',
          buttonBarPadding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            TextButton.icon(
              icon: Icon(Icons.folder, color: folderColor),
              onPressed: () => changeButton(ExpansionButtonType.folderFile),
              label: Text(
                'Folder',
                style: TextStyle(color: folderColor),
              ),
            ),
            TextButton.icon(
              icon: Icon(Icons.expand_more, color: arrowColor),
              onPressed: () => changeButton(ExpansionButtonType.chevron),
              label: Text(
                'Arrow',
                style: TextStyle(color: arrowColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
