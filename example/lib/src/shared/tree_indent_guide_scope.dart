import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:provider/provider.dart';

import '../settings/controller.dart';

class TreeIndentGuideScope extends StatelessWidget {
  const TreeIndentGuideScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SettingsController>().state;

    final IndentGuide guide;

    switch (state.indentType) {
      case IndentType.connectingLines:
        guide = IndentGuide.connectingLines(
          indent: state.indent,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          thickness: state.lineThickness,
          origin: state.lineOrigin,
          roundCorners: state.roundedCorners,
        );
        break;
      case IndentType.scopingLines:
        guide = IndentGuide.scopingLines(
          indent: state.indent,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(.3),
          thickness: state.lineThickness,
          origin: state.lineOrigin,
        );
        break;
      case IndentType.blank:
        guide = IndentGuide.blank(indent: state.indent);
        break;
    }

    return DefaultIndentGuide(
      guide: guide,
      child: child,
    );
  }
}
