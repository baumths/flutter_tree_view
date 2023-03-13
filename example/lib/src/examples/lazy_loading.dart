import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../shared.dart' show watchAnimationDurationSetting;

class Data {
  static const Data root = Data._root();

  const Data._root()
      : id = 0,
        title = '/';

  static int _uniqueId = 1;
  Data(this.title) : id = _uniqueId++;

  final int id;
  final String title;
}

class LazyLoadingTreeView extends StatefulWidget {
  const LazyLoadingTreeView({super.key});

  @override
  State<LazyLoadingTreeView> createState() => _LazyLoadingTreeViewState();
}

class _LazyLoadingTreeViewState extends State<LazyLoadingTreeView> {
  late final Random rng = Random();
  late final TreeController<Data> treeController;

  Iterable<Data> childrenProvider(Data data) {
    return childrenMap[data.id] ?? const Iterable.empty();
  }

  final Map<int, List<Data>> childrenMap = {
    Data.root.id: [Data('Root'), Data('Root'), Data('Root')],
  };

  final Set<int> loadingIds = {};

  Future<void> loadChildren(Data data) async {
    final List<Data>? children = childrenMap[data.id];
    if (children != null) return;

    setState(() {
      loadingIds.add(data.id);
    });

    await Future.delayed(const Duration(milliseconds: 750));

    childrenMap[data.id] = List.generate(
      rng.nextInt(4) + rng.nextInt(1),
      (_) => Data('Node'),
    );

    loadingIds.remove(data.id);
    if (mounted) setState(() {});

    treeController.expand(data);
  }

  Widget getLeadingFor(Data data) {
    if (loadingIds.contains(data.id)) {
      return const Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    late final VoidCallback? onPressed;
    late final bool? isOpen;

    final List<Data>? children = childrenMap[data.id];

    if (children == null) {
      isOpen = false;
      onPressed = () => loadChildren(data);
    } else if (children.isEmpty) {
      isOpen = null;
      onPressed = null;
    } else {
      isOpen = treeController.getExpansionState(data);
      onPressed = () => treeController.toggleExpansion(data);
    }

    return FolderButton(
      key: GlobalObjectKey(data.id),
      isOpen: isOpen,
      onPressed: onPressed,
    );
  }

  @override
  void initState() {
    super.initState();
    treeController = TreeController<Data>(
      roots: childrenProvider(Data.root),
      childrenProvider: childrenProvider,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTreeView<Data>(
      treeController: treeController,
      nodeBuilder: (_, TreeEntry<Data> entry) {
        return TreeIndentation(
          entry: entry,
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: getLeadingFor(entry.node),
              ),
              Text(entry.node.title),
            ],
          ),
        );
      },
      padding: const EdgeInsets.all(8),
      duration: watchAnimationDurationSetting(context),
    );
  }
}
