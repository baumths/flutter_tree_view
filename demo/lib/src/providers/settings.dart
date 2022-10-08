import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/indent_type.dart';

final showRootProvider = StateProvider<bool>((ref) => false);

final indentProvider = StateProvider<double>((ref) => 40.0);

final textDirectionProvider = StateProvider<TextDirection>(
  (ref) => TextDirection.ltr,
);

final roundedCornersProvider = StateProvider<bool>((ref) => false);

final lineThicknessProvider = StateProvider<double>((ref) => 2.5);

final lineOriginProvider = StateProvider<double>((ref) => 0.5);

final colorProvider = StateProvider<Color>((ref) => Colors.blue);

final colorSchemeProvider = StateProvider<ColorScheme>(
  (ref) => ColorScheme.fromSeed(seedColor: ref.watch(colorProvider)),
);

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
