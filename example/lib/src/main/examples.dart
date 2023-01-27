import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/tree_indent_guide_wrapper.dart';
import '../shared/utils.dart' show checkIsSmallDisplay;
import 'controller.dart';
import 'examples/_example.dart';

export 'examples/_example.dart';

class SelectedExampleView extends StatelessWidget {
  const SelectedExampleView({super.key, required this.example});

  final TreeViewExample example;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (_) => false,
        leading: (checkIsSmallDisplay(context))
            ? const SizedBox.square(dimension: 48)
            : null,
        actions: [
          IconButton(
            tooltip: 'Select another example',
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<SelectedExampleNotifier>().value = null;
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        title: Text('${example.title} TreeView'),
      ),
      body: TreeIndentGuideWrapper(
        child: example,
      ),
    );
  }
}

class ExamplesCatalogView extends StatelessWidget {
  const ExamplesCatalogView({
    super.key,
    required this.examples,
  });

  final List<TreeViewExample> examples;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (_) => false,
        automaticallyImplyLeading: false,
        leading: (checkIsSmallDisplay(context))
            ? const SizedBox.square(dimension: 48)
            : null,
        title: const Text('TreeView Examples'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: ExamplesCatalog(
        examples: examples,
        onExampleSelected: (index) {
          context.read<SelectedExampleNotifier>().value = index;
        },
      ),
    );
  }
}

class ExamplesCatalog extends StatelessWidget {
  const ExamplesCatalog({
    super.key,
    required this.examples,
    required this.onExampleSelected,
  });

  final List<TreeViewExample> examples;
  final ValueChanged<int> onExampleSelected;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: examples.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, int index) {
        final TreeViewExample example = examples[index];

        return ListTile(
          tileColor: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
          iconColor: colorScheme.onPrimaryContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          leading: example.icon,
          title: Text(example.title),
          onTap: () => onExampleSelected(index),
        );
      },
    );
  }
}
