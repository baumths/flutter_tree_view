import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/providers/responsive.dart';
import 'src/providers/settings.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Screen screen = ref.watch(screenProvider);

    return screen.when(
      small: () => Scaffold(
        appBar: AppBar(title: const Text('TreeView Demo')),
        drawer: const SettingsDrawer(),
        body: const Content(),
      ),
      large: () => const Scaffold(body: Content()),
    );
  }
}
