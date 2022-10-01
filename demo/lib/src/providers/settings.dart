import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/indent_type.dart';

final StateProvider<double> indentProvider = StateProvider(
  (ref) => 40.0,
);

final StateProvider<TextDirection> textDirectionProvider = StateProvider(
  (ref) => TextDirection.ltr,
);

final StateProvider<bool> roundedCornersProvider = StateProvider(
  (ref) => false,
);

final StateProvider<double> lineThicknessProvider = StateProvider(
  (ref) => 2.5,
);

final StateProvider<double> lineOriginProvider = StateProvider(
  (ref) => 0.5,
);

final StateProvider<Color> colorProvider = StateProvider(
  (ref) => Colors.blue,
);

final StateProvider<ColorScheme> colorSchemeProvider = StateProvider(
  (ref) => ColorScheme.fromSeed(
    seedColor: ref.watch(colorProvider),
  ),
);

final StateProvider<IndentType> indentTypeProvider = StateProvider(
  (ref) => IndentType.connectingLines,
);

final StateProvider<IndentGuide> indentGuideProvider = StateProvider(
  (ref) {
    final indent = ref.watch(indentProvider);

    late final lineThickness = ref.watch(lineThicknessProvider);
    late final lineColor = ref.watch(colorSchemeProvider).onSurfaceVariant;
    late final lineOrigin = ref.watch(lineOriginProvider);

    switch (ref.watch(indentTypeProvider)) {
      case IndentType.connectingLines:
        return ConnectingLinesGuide(
          roundCorners: ref.watch(roundedCornersProvider),
          indent: indent,
          thickness: lineThickness,
          origin: lineOrigin,
          color: lineColor,
        );
      case IndentType.scopingLines:
        return ScopingLinesGuide(
          indent: indent,
          thickness: lineThickness,
          origin: lineOrigin,
          color: lineColor,
        );
      case IndentType.empty:
        return IndentGuide(indent: indent);
    }
  },
);
