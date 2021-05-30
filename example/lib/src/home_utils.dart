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
    required this.controller,
    required this.changeLineStyle,
    required this.changeNodeIcon,
    required this.changeTreeController,
  }) : super(key: key);

  final TreeViewController controller;

  final VoidCallback changeLineStyle;

  final VoidCallback changeNodeIcon;

  final VoidCallback changeTreeController;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      overlayColor: Colors.transparent,
      overlayOpacity: 0.0,
      backgroundColor: kDarkBlue,
      foregroundColor: Colors.white,
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
          foregroundColor: Colors.white,
        ),
        SpeedDialChild(
          label: 'Change Line Style',
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.orange.shade900,
          onTap: changeLineStyle,
          foregroundColor: Colors.white,
        ),
        SpeedDialChild(
          label: 'Change Node Icons',
          child: const Icon(Icons.swap_vert_rounded),
          backgroundColor: Colors.yellow.shade900,
          onTap: changeNodeIcon,
          foregroundColor: Colors.white,
        ),
        SpeedDialChild(
          label: 'Collapse All',
          child: const Icon(Icons.unfold_less),
          backgroundColor: Colors.red,
          onTap: controller.collapseAll,
          foregroundColor: Colors.white,
        ),
        SpeedDialChild(
          label: 'Expand All',
          child: const Icon(Icons.unfold_more),
          backgroundColor: Colors.green,
          onTap: controller.expandAll,
          foregroundColor: Colors.white,
        ),
      ],
    );
  }
}

class _LineThicknessSlider extends StatefulWidget {
  const _LineThicknessSlider({
    Key? key,
    this.onChanged,
  }) : super(key: key);

  final ValueChanged<double>? onChanged;

  @override
  __LineThicknessSliderState createState() => __LineThicknessSliderState();
}

class __LineThicknessSliderState extends State<_LineThicknessSlider> {
  var value = 2.0;

  void update(double val) {
    setState(() => value = val);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black45),
        ],
      ),
      child: Slider(
        value: value,
        onChanged: update,
        max: 8,
        divisions: 7,
        min: 1,
        label: 'Line Thickness: $value',
        activeColor: kDarkBlue,
        onChangeEnd: widget.onChanged,
      ),
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
