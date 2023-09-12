import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:provider/provider.dart';

import 'examples/drag_and_drop.dart' show DragAndDropTreeView;
import 'examples/lazy_loading.dart' show LazyLoadingTreeView;
import 'examples/minimal.dart' show MinimalTreeView;
import 'settings/controller.dart' show IndentType, SettingsController;

class SelectedExampleNotifier extends ValueNotifier<Example> {
  SelectedExampleNotifier() : super(Example.minimal);

  void select(Example? example) {
    if (example == null) return;
    value = example;
  }
}

enum Example {
  dragAndDrop('Drag and Drop', Icon(Icons.move_down_rounded)),
  lazyLoading('Lazy Loading', Icon(Icons.hourglass_top_rounded)),
  minimal('Minimal', Icon(Icons.segment));

  const Example(this.title, this.icon);

  final String title;
  final Widget icon;

  Widget get tree {
    return switch (this) {
      Example.dragAndDrop => const DragAndDropTreeView(),
      Example.lazyLoading => const LazyLoadingTreeView(),
      Example.minimal => const MinimalTreeView(),
    };
  }
}

class ExamplesView extends StatelessWidget {
  const ExamplesView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedExample = context.watch<SelectedExampleNotifier>().value;

    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: TreeIndentGuideScope(
        key: Key(selectedExample.title),
        child: selectedExample.tree,
      ),
    );
  }
}

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
          color: Theme.of(context).colorScheme.outline,
          thickness: state.lineThickness,
          origin: state.lineOrigin,
          strokeCap: StrokeCap.round,
          pathModifier: state.lineStyle.toPathModifier(),
          roundCorners: state.roundedCorners,
          connectBranches: state.connectBranches,
        );
        break;
      case IndentType.scopingLines:
        guide = IndentGuide.scopingLines(
          indent: state.indent,
          color: Theme.of(context).colorScheme.outline,
          thickness: state.lineThickness,
          origin: state.lineOrigin,
          strokeCap: StrokeCap.round,
          pathModifier: state.lineStyle.toPathModifier(),
        );
        break;
      case IndentType.blank:
        guide = IndentGuide(indent: state.indent);
        break;
    }

    return DefaultIndentGuide(
      guide: guide,
      child: child,
    );
  }
}
