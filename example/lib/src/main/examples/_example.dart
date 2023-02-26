import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../settings/controller.dart';

export 'basic.dart' show BasicTreeView;
export 'lazy_loading.dart' show LazyLoadingTreeView;

mixin TreeViewExample on Widget {
  String get title;
  Widget? get icon => null;

  static Duration watchAnimationDurationSetting(BuildContext context) {
    final animateExpansions = context.select<SettingsController, bool>(
      (controller) => controller.state.animateExpansions,
    );

    return animateExpansions
        ? const Duration(milliseconds: 300)
        : Duration.zero;
  }
}
