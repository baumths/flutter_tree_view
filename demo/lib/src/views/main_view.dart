import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/responsive.dart';
import 'main/tree_view.dart';
import 'settings.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Screen screen = ref.watch(screenProvider);

    return screen.when(
      small: () => const DemoTreeView(),
      large: () => Row(
        children: const [
          Settings(),
          Expanded(child: DemoTreeView()),
        ],
      ),
    );
  }
}
