import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

enum IndentType {
  connectingLines('Connecting Lines'),
  scopingLines('Scoping Lines'),
  blank('Blank');

  final String title;

  const IndentType(this.title);

  static Iterable<IndentType> allExcept(IndentType type) {
    return values.where((element) => element != type);
  }
}

enum LineStyle {
  dashed('Dashed'),
  dotted('Dotted'),
  solid('Solid');

  final String title;
  const LineStyle(this.title);

  Path Function(Path)? toPathModifier() => switch (this) {
        dashed => (Path path) => dashPath(
              path,
              dashArray: CircularIntervalList(const [6, 4]),
              dashOffset: const DashOffset.absolute(6 / 4),
            ),
        dotted => (Path path) => dashPath(
              path,
              dashArray: CircularIntervalList(const [0.5, 3.5]),
              dashOffset: const DashOffset.absolute(0.5 * 3.5),
            ),
        solid => null,
      };
}

class SettingsState {
  const SettingsState({
    this.animateExpansions = true,
    this.brightness = Brightness.light,
    this.color = Colors.blue,
    this.indent = 40.0,
    this.indentType = IndentType.connectingLines,
    this.lineOrigin = 0.5,
    this.lineThickness = 2.0,
    this.roundedCorners = false,
    this.textDirection = TextDirection.ltr,
    this.lineStyle = LineStyle.solid,
  });

  final bool animateExpansions;
  final Brightness brightness;
  final Color color;
  final double indent;
  final IndentType indentType;
  final double lineOrigin;
  final double lineThickness;
  final bool roundedCorners;
  final TextDirection textDirection;
  final LineStyle lineStyle;

  SettingsState copyWith({
    bool? animateExpansions,
    Brightness? brightness,
    Color? color,
    double? indent,
    IndentType? indentType,
    double? lineOrigin,
    double? lineThickness,
    bool? roundedCorners,
    TextDirection? textDirection,
    LineStyle? lineStyle,
  }) {
    return SettingsState(
      animateExpansions: animateExpansions ?? this.animateExpansions,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      indent: indent ?? this.indent,
      indentType: indentType ?? this.indentType,
      lineOrigin: lineOrigin ?? this.lineOrigin,
      lineThickness: lineThickness ?? this.lineThickness,
      roundedCorners: roundedCorners ?? this.roundedCorners,
      textDirection: textDirection ?? this.textDirection,
      lineStyle: lineStyle ?? this.lineStyle,
    );
  }
}

class SettingsController with ChangeNotifier {
  SettingsController({
    SettingsState state = const SettingsState(),
  }) : _state = state;

  SettingsState get state => _state;
  late SettingsState _state;
  @protected
  set state(SettingsState state) {
    _state = state;
    notifyListeners();
  }

  void restoreAll() {
    state = const SettingsState();
  }

  void updateAnimateExpansions(bool value) {
    if (value == state.animateExpansions) return;
    state = state.copyWith(animateExpansions: value);
  }

  void updateBrightness(Brightness value) {
    if (state.brightness == value) return;
    state = state.copyWith(brightness: value);
  }

  void updateColor(Color value) {
    if (state.color == value) return;
    state = state.copyWith(color: value);
  }

  void updateIndent(double value) {
    if (state.indent == value) return;
    state = state.copyWith(indent: value);
  }

  void updateIndentType(IndentType value) {
    if (state.indentType == value) return;
    state = state.copyWith(indentType: value);
  }

  void updateLineOrigin(double value) {
    if (state.lineOrigin == value) return;
    state = state.copyWith(lineOrigin: value);
  }

  void updateLineThickness(double value) {
    if (state.lineThickness == value) return;
    state = state.copyWith(lineThickness: value);
  }

  void updateRoundedCorners(bool value) {
    if (state.roundedCorners == value) return;
    state = state.copyWith(roundedCorners: value);
  }

  void updateTextDirection(TextDirection value) {
    if (state.textDirection == value) return;
    state = state.copyWith(textDirection: value);
  }

  void updateLineStyle(LineStyle value) {
    if (state.lineStyle == value) return;
    state = state.copyWith(lineStyle: value);
  }
}
