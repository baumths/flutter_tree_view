part of 'settings_view.dart';

class _LineThicknessSlider extends StatefulWidget {
  const _LineThicknessSlider({Key? key}) : super(key: key);

  @override
  __LineThicknessSliderState createState() => __LineThicknessSliderState();
}

class __LineThicknessSliderState extends State<_LineThicknessSlider> {
  var value = 2.0;

  void update(double val) => setState(() => value = val);

  @override
  Widget build(BuildContext context) {
    return _SettingsButtonBar(
      label: 'Line Thickness: $value',
      singleChildPadding: EdgeInsets.zero,
      children: [
        Slider(
          value: value,
          onChanged: update,
          max: 8,
          divisions: 7,
          min: 1,
          label: '$value',
          activeColor: kDarkBlue,
          onChangeEnd: _updateLineThickness,
        ),
      ],
    );
  }

  void _updateLineThickness(double lineThickness) {
    final appController = AppController.of(context);
    appController.updateTheme(
      appController.treeViewTheme.value.copyWith(
        lineThickness: lineThickness,
      ),
    );
  }
}
