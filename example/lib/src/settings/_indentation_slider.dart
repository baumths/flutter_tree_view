part of 'settings_view.dart';

class _IndentationSlider extends StatefulWidget {
  const _IndentationSlider({Key? key}) : super(key: key);

  @override
  __IndentationSliderState createState() => __IndentationSliderState();
}

class __IndentationSliderState extends State<_IndentationSlider> {
  var value = 40.0;

  void update(double val) => setState(() => value = val);

  @override
  Widget build(BuildContext context) {
    return _SettingsButtonBar(
      label: 'Node indent increment: $value',
      singleChildPadding: EdgeInsets.zero,
      children: [
        Slider(
          value: value,
          onChanged: update,
          max: 64.0,
          divisions: 7,
          min: 8.0,
          label: '$value',
          activeColor: kDarkBlue,
          onChangeEnd: _updateIndent,
        ),
      ],
    );
  }

  void _updateIndent(double indent) {
    final appController = AppController.of(context);

    appController.updateTheme(
      appController.treeViewTheme.value.copyWith(
        indent: indent,
      ),
    );
  }
}
