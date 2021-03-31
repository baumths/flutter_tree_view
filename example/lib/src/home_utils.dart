part of 'home_page.dart';

void showSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 1),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
}

class _SpeedDial extends StatelessWidget {
  const _SpeedDial({
    Key? key,
    required this.treeController,
    required this.changeLineStyle,
    required this.changeNodeIcon,
    required this.changeTreeController,
  }) : super(key: key);

  final TreeViewController treeController;

  final VoidCallback changeLineStyle;

  final VoidCallback changeNodeIcon;

  final VoidCallback changeTreeController;

  @override
  Widget build(BuildContext context) {
    final _primaryColor = Theme.of(context).primaryColor;

    return SpeedDial(
      overlayColor: Colors.transparent,
      overlayOpacity: 0.0,
      backgroundColor: _primaryColor,
      closeManually: true,
      curve: Curves.fastOutSlowIn,
      activeIcon: Icons.close,
      icon: Icons.menu,
      children: [
        SpeedDialChild(
          label: 'Change Controller',
          child: const Icon(Icons.apps_outlined),
          backgroundColor: Colors.deepPurple.shade600,
          onTap: changeTreeController,
        ),
        SpeedDialChild(
          label: 'Change Line Style',
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.orange.shade900,
          onTap: changeLineStyle,
        ),
        SpeedDialChild(
          label: 'Change Node Icons',
          child: const Icon(Icons.swap_vert_rounded),
          backgroundColor: Colors.yellow.shade900,
          onTap: changeNodeIcon,
        ),
        SpeedDialChild(
          label: 'Collapse All',
          child: const Icon(Icons.unfold_less),
          backgroundColor: Colors.red,
          onTap: treeController.collapseAll,
        ),
        SpeedDialChild(
          label: 'Expand All',
          child: const Icon(Icons.unfold_more),
          backgroundColor: Colors.green,
          onTap: treeController.expandAll,
        ),
      ],
    );
  }
}

class FindNodeDialog extends StatefulWidget {
  const FindNodeDialog({Key? key}) : super(key: key);

  @override
  _FindNodeDialogState createState() => _FindNodeDialogState();
}

class _FindNodeDialogState extends State<FindNodeDialog> {
  static const buttonPadding = EdgeInsets.symmetric(horizontal: 40);

  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode()..requestFocus();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SizedBox(
      width: 256,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text('Reveal a Node in the Tree', style: textTheme.headline6),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              focusNode: _focusNode,
              controller: _textEditingController,
              decoration: const InputDecoration(
                labelText: 'Input an ID',
                border: OutlineInputBorder(),
              ),
              onSubmitted: Navigator.of(context).pop,
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(padding: buttonPadding),
                onPressed: Navigator.of(context).pop,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: theme.primaryColor,
                  textStyle: textTheme.button,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                ),
                onPressed: () {
                  Navigator.of(context).pop(_textEditingController.text);
                },
                child: const Text('Find'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
