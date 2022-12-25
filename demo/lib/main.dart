import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers/responsive.dart';
import 'src/providers/settings.dart';
import 'src/tree.dart';
import 'src/views/content.dart';
import 'src/views/settings.dart';

void main() => runApp(const ProviderScope(child: DemoApp()));

class DemoApp extends ConsumerWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'TreeView Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ref.watch(colorSchemeProvider),
      ),
      builder: (BuildContext context, Widget? child) {
        final double maxWidth = MediaQuery.of(context).size.width;

        return ProviderScope(
          overrides: [screenWidthProvider.overrideWithValue(maxWidth)],
          child: DirectionalityWrapper(
            child: child!,
          ),
        );
      },
      home: const DemoPage(),
    );
  }
}

class DirectionalityWrapper extends ConsumerWidget {
  const DirectionalityWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: ref.watch(textDirectionProvider),
      child: child,
    );
  }
}

class DemoPage extends ConsumerWidget {
  const DemoPage({super.key});

  static final GlobalKey<ScaffoldState> _smallScaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Screen screen = ref.watch(screenProvider);

    ref.listen(screenWidthProvider, (previous, next) {
      if (previous == null) return;

      if (next < previous) {
        _smallScaffoldKey.currentState?.closeDrawer();
      }
    });

    return screen.when(
      small: () => Scaffold(
        key: _smallScaffoldKey,
        appBar: AppBar(
          title: const Text('TreeView Demo'),
          notificationPredicate: (_) => false,
        ),
        drawer: const SettingsDrawer(),
        body: const Content(),
        floatingActionButton: const ExpansionFabs(),
      ),
      large: () => const Scaffold(
        body: Content(),
        floatingActionButton: ExpansionFabs.large(),
      ),
    );
  }
}

class ExpansionFabs extends ConsumerWidget {
  const ExpansionFabs({super.key}) : large = false;

  const ExpansionFabs.large({super.key}) : large = true;

  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: .9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            isExtended: large,
            elevation: 1,
            extendedPadding: const EdgeInsets.all(16),
            label: const Text('Expand All'),
            tooltip: large ? null : 'Expand All',
            icon: const Icon(Icons.fullscreen),
            onPressed: () => ref.read(treeControllerProvider).expandAll(),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            isExtended: large,
            elevation: 1,
            extendedPadding: const EdgeInsets.all(16),
            label: const Text('Collapse All'),
            tooltip: large ? null : 'Collapse All',
            icon: const Icon(Icons.fullscreen_exit),
            onPressed: () => ref.read(treeControllerProvider).collapseAll(),
          ),
        ],
      ),
    );
  }
}
