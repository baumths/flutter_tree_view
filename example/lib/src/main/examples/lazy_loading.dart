import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '_example.dart';

class Data {
  static const int rootId = 0;

  static int _uniqueId = 1;
  Data(this.title) : id = _uniqueId++;

  final int id;
  final String title;
}

class LazyLoadingTreeView extends StatefulWidget with TreeViewExample {
  const LazyLoadingTreeView({super.key});

  @override
  State<LazyLoadingTreeView> createState() => _LazyLoadingTreeViewState();

  @override
  String get title => 'Lazy Loading';

  @override
  Widget? get icon => const Icon(Icons.hourglass_top_rounded);
}

class _LazyLoadingTreeViewState extends State<LazyLoadingTreeView> {
  late final Random rng = Random();
  late final TreeController<Data> treeController;

  Iterable<Data> get roots => childrenMap[Data.rootId]!;

  Iterable<Data> childrenProvider(Data data) {
    return childrenMap[data.id] ?? const Iterable.empty();
  }

  final Map<int, List<Data>> childrenMap = {
    Data.rootId: [Data('Root'), Data('Root'), Data('Root')],
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
      isOpen = treeController.expansionState.get(data);
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
    treeController = TreeController();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<Data>(
      roots: roots,
      childrenProvider: childrenProvider,
      treeController: treeController,
      nodeBuilder: (_, TreeEntry<Data> entry) {
        return TreeIndentation(
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
      rootLevel: TreeViewExample.watchRootLevelSetting(context),
      animationDuration: TreeViewExample.watchAnimationDurationSetting(context),
    );
  }
}
