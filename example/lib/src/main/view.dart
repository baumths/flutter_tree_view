import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/tree_indent_guide_scope.dart';
import '../shared/utils.dart';
import 'controller.dart';
import 'examples/_example.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    const List<TreeViewExample> examples = [
      DragAndDropTreeView(),
      LazyLoadingTreeView(),
    ];

    final selectedExampleIndex = context.watch<SelectedExampleNotifier>().value;

    final Widget title;
    final Widget body;
    List<Widget>? actions;

    if (selectedExampleIndex == null) {
      title = const Text('TreeView Examples');
      body = ExamplesCatalog(
        examples: examples,
        onExampleSelected: (index) {
          context.read<SelectedExampleNotifier>().value = index;
        },
      );
    } else {
      final selectedExample = examples[selectedExampleIndex];

      title = Text('${selectedExample.title} TreeView');
      body = TreeIndentGuideScope(child: selectedExample);
      actions = <Widget>[
        IconButton(
          tooltip: 'Select another example',
          icon: const Icon(Icons.close),
          onPressed: () {
            context.read<SelectedExampleNotifier>().value = null;
          },
        ),
        const SizedBox(width: 8),
      ];
    }

    Widget? leading;
    if (checkIsSmallDisplay(context)) {
      // On smaller displays, add some empty leading space so that the app
      // scaffold can place a FAB there to open the settings drawer.
      leading = const SizedBox.square(dimension: 48);
    }

    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (_) => false,
        automaticallyImplyLeading: false,
        leading: leading,
        title: title,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
        actions: actions,
      ),
      body: body,
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
