import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../shared.dart' show IndentGuideType, LineStyle, enumByName;

class SettingsState {
  const SettingsState({
    this.animateExpansions = false,
    this.color = Colors.blue,
    this.connectBranches = false,
    this.indent = 40.0,
    this.indentGuideType = IndentGuideType.connectingLines,
    this.lineOrigin = 0.5,
    this.lineStyle = LineStyle.solid,
    this.lineThickness = 2.0,
    this.roundedCorners = false,
    this.textDirection = TextDirection.ltr,
    this.themeMode = ThemeMode.system,
  });

  factory SettingsState.fromPreferences(SharedPreferences prefs) {
    return const SettingsState().copyWith(
      animateExpansions: prefs.getBool(animateExpansionsKey),
      color: Color(prefs.getInt(colorKey) ?? Colors.blue.value),
      connectBranches: prefs.getBool(connectBranchesKey),
      indent: prefs.getDouble(indentKey),
      indentGuideType: enumByName(
          prefs.getString(indentGuideTypeKey), IndentGuideType.values),
      lineOrigin: prefs.getDouble(lineOriginKey),
      lineStyle: enumByName(prefs.getString(lineStyleKey), LineStyle.values),
      lineThickness: prefs.getDouble(lineThicknessKey),
      roundedCorners: prefs.getBool(roundedCornersKey),
      textDirection:
          enumByName(prefs.getString(textDirectionKey), TextDirection.values),
      themeMode: enumByName(prefs.getString(themeModeKey), ThemeMode.values),
    );
  }

  final bool animateExpansions;
  final Color color;
  final bool connectBranches;
  final double indent;
  final IndentGuideType indentGuideType;
  final double lineOrigin;
  final LineStyle lineStyle;
  final double lineThickness;
  final bool roundedCorners;
  final TextDirection textDirection;
  final ThemeMode themeMode;

  SettingsState copyWith({
    bool? animateExpansions,
    Color? color,
    bool? connectBranches,
    double? indent,
    IndentGuideType? indentGuideType,
    double? lineOrigin,
    LineStyle? lineStyle,
    double? lineThickness,
    bool? roundedCorners,
    TextDirection? textDirection,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      animateExpansions: animateExpansions ?? this.animateExpansions,
      color: color ?? this.color,
      connectBranches: connectBranches ?? this.connectBranches,
      indent: indent ?? this.indent,
      indentGuideType: indentGuideType ?? this.indentGuideType,
      lineOrigin: lineOrigin ?? this.lineOrigin,
      lineStyle: lineStyle ?? this.lineStyle,
      lineThickness: lineThickness ?? this.lineThickness,
      roundedCorners: roundedCorners ?? this.roundedCorners,
      textDirection: textDirection ?? this.textDirection,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsController with ChangeNotifier {
  SettingsController(this.prefs)
      : _state = SettingsState.fromPreferences(prefs);

  final SharedPreferences prefs;

  SettingsState get state => _state;
  late SettingsState _state;
  @protected
  set state(SettingsState state) {
    _state = state;
    notifyListeners();
  }

  void reset() {
    state = const SettingsState();
    prefs.clear();
  }

  void updateAnimateExpansions(bool value) {
    if (value == state.animateExpansions) return;
    state = state.copyWith(animateExpansions: value);
    prefs.setBool(animateExpansionsKey, value);
  }

  void updateColor(Color value) {
    if (state.color == value) return;
    state = state.copyWith(color: value);
    prefs.setInt(colorKey, value.value);
  }

  void updateConnectBranches(bool value) {
    if (state.connectBranches == value) return;
    state = state.copyWith(connectBranches: value);
    prefs.setBool(connectBranchesKey, value);
  }

  void updateIndent(double value) {
    if (state.indent == value) return;
    state = state.copyWith(indent: value);
    prefs.setDouble(indentKey, value);
  }

  void updateIndentGuideType(IndentGuideType value) {
    if (state.indentGuideType == value) return;
    state = state.copyWith(indentGuideType: value);
    prefs.setString(indentGuideTypeKey, value.name);
  }

  void updateLineOrigin(double value) {
    if (state.lineOrigin == value) return;
    state = state.copyWith(lineOrigin: value);
    prefs.setDouble(lineOriginKey, value);
  }

  void updateLineStyle(LineStyle value) {
    if (state.lineStyle == value) return;
    state = state.copyWith(lineStyle: value);
    prefs.setString(lineStyleKey, value.name);
  }

  void updateLineThickness(double value) {
    if (state.lineThickness == value) return;
    state = state.copyWith(lineThickness: value);
    prefs.setDouble(lineThicknessKey, value);
  }

  void updateRoundedCorners(bool value) {
    if (state.roundedCorners == value) return;
    state = state.copyWith(roundedCorners: value);
    prefs.setBool(roundedCornersKey, value);
  }

  void updateTextDirection(TextDirection value) {
    if (state.textDirection == value) return;
    state = state.copyWith(textDirection: value);
    prefs.setString(textDirectionKey, value.name);
  }

  void updateThemeMode(ThemeMode value) {
    if (state.themeMode == value) return;
    state = state.copyWith(themeMode: value);
    prefs.setString(themeModeKey, value.name);
  }
}

const animateExpansionsKey = 'fftv.animateExpansions';
const colorKey = 'fftv.color';
const connectBranchesKey = 'fftv.connectBranches';
const indentKey = 'fftv.indent';
const indentGuideTypeKey = 'fftv.indentGuideType';
const lineOriginKey = 'fftv.lineOrigin';
const lineStyleKey = 'fftv.lineStyle';
const lineThicknessKey = 'fftv.lineThickness';
const roundedCornersKey = 'fftv.roundedCorners';
const textDirectionKey = 'fftv.textDirection';
const themeModeKey = 'fftv.themeMode';
