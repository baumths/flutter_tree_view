import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'examples/drag_and_drop.dart' show DragAndDropTreeView;
import 'examples/filterable.dart' show FilterableTreeView;
import 'examples/lazy_loading.dart' show LazyLoadingTreeView;
import 'examples/minimal.dart' show MinimalTreeView;
import 'examples/selectable.dart' show SelectableTreeView;
import 'settings/controller.dart' show SettingsController;
import 'shared.dart' show IndentGuideType, LineStyle, enumByName;

const selectedExampleKey = 'fftv.selectedExample';

class SelectedExampleNotifier extends ValueNotifier<Example> {
  SelectedExampleNotifier(this.prefs)
      : super(Example.byName(prefs.getString(selectedExampleKey)));

  final SharedPreferences prefs;

  void select(Example? example) {
    if (example == null || example == value) return;
    value = example;
    prefs.setString(selectedExampleKey, example.name);
  }

  void reset() {
    if (value == Example.minimal) return;
    value = Example.minimal;
    prefs.remove(selectedExampleKey);
  }
}

enum Example {
  dragAndDrop('Drag and Drop', Icon(Icons.move_down_rounded)),
  filterable('Filterable', Icon(Icons.manage_search_rounded)),
  lazyLoading('Lazy Loading', Icon(Icons.hourglass_top_rounded)),
  minimal('Minimal', Icon(Icons.segment)),
  selectable('Selectable', Icon(Icons.check_box)),
  ;

  const Example(this.title, this.icon);
  final String title;
  final Widget icon;

  static Example byName(String? name) => enumByName(name, values) ?? minimal;
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
        child: switch (selectedExample) {
          Example.dragAndDrop => const DragAndDropTreeView(),
          Example.filterable => const FilterableTreeView(),
          Example.lazyLoading => const LazyLoadingTreeView(),
          Example.minimal => const MinimalTreeView(),
          Example.selectable => const SelectableTreeView(),
        },
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

    switch (state.indentGuideType) {
      case IndentGuideType.connectingLines:
        guide = IndentGuide.connectingLines(
          indent: state.indent,
          color: Theme.of(context).colorScheme.outline,
          thickness: state.lineThickness,
          origin: state.lineOrigin,
          strokeCap: StrokeCap.round,
          pathModifier: getPathModifierFor(state.lineStyle),
          roundCorners: state.roundedCorners,
          connectBranches: state.connectBranches,
        );
        break;
      case IndentGuideType.scopingLines:
        guide = IndentGuide.scopingLines(
          indent: state.indent,
          color: Theme.of(context).colorScheme.outline,
          thickness: state.lineThickness,
          origin: state.lineOrigin,
          strokeCap: StrokeCap.round,
          pathModifier: getPathModifierFor(state.lineStyle),
        );
        break;
      case IndentGuideType.blank:
        guide = IndentGuide(indent: state.indent);
        break;
    }

    return DefaultIndentGuide(
      guide: guide,
      child: child,
    );
  }

  Path Function(Path)? getPathModifierFor(LineStyle lineStyle) {
    return switch (lineStyle) {
      LineStyle.dashed => (Path path) => dashPath(
            path,
            dashArray: CircularIntervalList(const [6, 4]),
            dashOffset: const DashOffset.absolute(6 / 4),
          ),
      LineStyle.dotted => (Path path) => dashPath(
            path,
            dashArray: CircularIntervalList(const [0.5, 3.5]),
            dashOffset: const DashOffset.absolute(0.5 * 3.5),
          ),
      LineStyle.solid => null,
    };
  }
}
