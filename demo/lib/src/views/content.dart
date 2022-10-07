import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/responsive.dart';
import 'content/view.dart';
import 'settings.dart';

class Content extends ConsumerWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Screen screen = ref.watch(screenProvider);

    return screen.when(
      small: () => const ContentView(),
      large: () => Row(
        children: const [
          Settings(),
          Expanded(child: ContentView()),
        ],
      ),
    );
  }
}
