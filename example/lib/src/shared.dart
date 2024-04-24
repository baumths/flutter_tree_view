import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'settings/controller.dart';

T? enumByName<T extends Enum>(String? name, List<T> values) {
  return name == null ? null : values.byName(name);
}

enum IndentGuideType {
  blank('Blank'),
  connectingLines('Connecting Lines'),
  scopingLines('Scoping Lines'),
  ;

  const IndentGuideType(this.title);
  final String title;
}

enum LineStyle {
  dashed('Dashed'),
  dotted('Dotted'),
  solid('Solid'),
  ;

  const LineStyle(this.title);
  final String title;
}

Duration watchAnimationDurationSetting(BuildContext context) {
  final animateExpansions = context.select<SettingsController, bool>(
    (controller) => controller.state.animateExpansions,
  );

  return animateExpansions ? const Duration(milliseconds: 300) : Duration.zero;
}
