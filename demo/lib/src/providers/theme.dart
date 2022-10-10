import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final textDirectionProvider = StateProvider<TextDirection>(
  (ref) => TextDirection.ltr,
);

final brightnessProvider = StateProvider((ref) => Brightness.light);

final colorProvider = StateProvider<Color>((ref) => Colors.blue);

final colorSchemeProvider = StateProvider<ColorScheme>(
  (ref) => ColorScheme.fromSeed(
    seedColor: ref.watch(colorProvider),
    brightness: ref.watch(brightnessProvider),
  ),
);
