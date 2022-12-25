import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tree_view.dart';

class ContentView extends ConsumerWidget {
  const ContentView({super.key});

  // This key makes sure the auto scroller inside [SliverTree] doesn't explode
  // after the user resizes the screen.
  static final GlobalKey _treeViewKey = GlobalKey();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NodeTreeView(
      key: _treeViewKey,
    );
  }
}
