import 'package:flutter/material.dart';

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

class SettingsState {
  const SettingsState({
    this.animateExpansions = true,
    this.brightness = Brightness.light,
    this.color = Colors.blue,
    this.indent = 40.0,
    this.indentType = IndentType.connectingLines,
    this.lineOrigin = 0.5,
    this.lineThickness = 2.0,
    this.rootLevel = 0,
    this.roundedCorners = false,
    this.textDirection = TextDirection.ltr,
  });

  final bool animateExpansions;
  final Brightness brightness;
  final Color color;
  final double indent;
  final IndentType indentType;
  final double lineOrigin;
  final double lineThickness;
  final int rootLevel;
  final bool roundedCorners;
  final TextDirection textDirection;

  SettingsState copyWith({
    bool? animateExpansions,
    Brightness? brightness,
    Color? color,
    double? indent,
    IndentType? indentType,
    double? lineOrigin,
    double? lineThickness,
    int? rootLevel,
    bool? roundedCorners,
    TextDirection? textDirection,
  }) {
    return SettingsState(
      animateExpansions: animateExpansions ?? this.animateExpansions,
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      indent: indent ?? this.indent,
      indentType: indentType ?? this.indentType,
      lineOrigin: lineOrigin ?? this.lineOrigin,
      lineThickness: lineThickness ?? this.lineThickness,
      rootLevel: rootLevel ?? this.rootLevel,
      roundedCorners: roundedCorners ?? this.roundedCorners,
      textDirection: textDirection ?? this.textDirection,
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

  void updateRootLevel(int value) {
    if (state.rootLevel == value) return;
    state = state.copyWith(rootLevel: value);
  }

  void updateRoundedCorners(bool value) {
    if (state.roundedCorners == value) return;
    state = state.copyWith(roundedCorners: value);
  }

  void updateTextDirection(TextDirection value) {
    if (state.textDirection == value) return;
    state = state.copyWith(textDirection: value);
  }
}
