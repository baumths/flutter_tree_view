import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/indent_type.dart';
import 'theme.dart';

export 'theme.dart';

final rootLevelProvider = StateProvider<int>((ref) => 0);

final animatedExpansionsProvider = StateProvider<bool>((ref) => true);

final indentProvider = StateProvider<double>((ref) => 40.0);

final roundedCornersProvider = StateProvider<bool>((ref) => false);

final lineThicknessProvider = StateProvider<double>((ref) => 2.5);

final lineOriginProvider = StateProvider<double>((ref) => 0.5);

final indentTypeProvider = StateProvider<IndentType>(
  (ref) => IndentType.connectingLines,
);

final indentGuideProvider = StateProvider<IndentGuide>(
  (ref) {
    final indent = ref.watch(indentProvider);

    late final lineThickness = ref.watch(lineThicknessProvider);
    late final lineColor = ref.watch(colorSchemeProvider).onSurfaceVariant;
    late final lineOrigin = ref.watch(lineOriginProvider);

    switch (ref.watch(indentTypeProvider)) {
      case IndentType.connectingLines:
        return IndentGuide.connectingLines(
          roundCorners: ref.watch(roundedCornersProvider),
          indent: indent,
          thickness: lineThickness,
          origin: lineOrigin,
          color: lineColor,
        );
      case IndentType.scopingLines:
        return IndentGuide.scopingLines(
          indent: indent,
          thickness: lineThickness,
          origin: lineOrigin,
          color: lineColor,
        );
      case IndentType.blank:
        return IndentGuide.blank(indent: indent);
    }
  },
);
