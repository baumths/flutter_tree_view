import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'settings/controller.dart';

Duration watchAnimationDurationSetting(BuildContext context) {
  final animateExpansions = context.select<SettingsController, bool>(
    (controller) => controller.state.animateExpansions,
  );

  return animateExpansions ? const Duration(milliseconds: 300) : Duration.zero;
}
