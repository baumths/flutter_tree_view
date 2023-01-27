import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'examples.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<TreeViewExample> examples = [
      DragAndDropTreeView(),
      LazyLoadingTreeView(),
    ];

    final examplesController = context.watch<SelectedExampleNotifier>();
    final selectedExampleIndex = examplesController.value;

    if (selectedExampleIndex == null) {
      return const ExamplesCatalogView(examples: examples);
    }

    return SelectedExampleView(
      example: examples[selectedExampleIndex],
    );
  }
}
