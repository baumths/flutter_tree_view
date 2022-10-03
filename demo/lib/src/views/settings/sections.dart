import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings.dart';
import '../../shared/indent_type.dart';

import 'sections/color.dart';
import 'sections/indent.dart';
import 'sections/line_origin.dart';
import 'sections/indent_guide_type.dart';
import 'sections/line_thickness.dart';
import 'sections/rounded_connections.dart';
import 'sections/text_direction.dart';

class Sections extends ConsumerWidget {
  const Sections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indentType = ref.watch(indentTypeProvider);

    return ListView(
      children: [
        const ColorSelector(),
        const Indent(),
        const Direction(),
        const IndentGuideType(),
        if (indentType != IndentType.empty) ...[
          if (indentType != IndentType.scopingLines) const RoundedConnections(),
          const LineThickness(),
          const LineOrigin(),
        ],
      ],
    );
  }
}