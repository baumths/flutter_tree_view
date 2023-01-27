import 'package:flutter/material.dart';

import '_example.dart';

class DragAndDropTreeView extends StatefulWidget with TreeViewExample {
  const DragAndDropTreeView({super.key});

  @override
  State<DragAndDropTreeView> createState() => _DragAndDropTreeViewState();

  @override
  String get title => 'Drag & Drop';

  @override
  Widget? get icon => const Icon(Icons.move_down_rounded);
}

class _DragAndDropTreeViewState extends State<DragAndDropTreeView> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
