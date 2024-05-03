import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart'
    hide SliverAnimatedTree, AnimatedTreeView;

import '../tree_data.dart' show generateTreeNodes;

class Node {
  Node({required this.title}) : children = <Node>[];

  final String title;
  final List<Node> children;
}

class AnimatedTreeView extends StatefulWidget {
  const AnimatedTreeView({super.key});

  @override
  State<AnimatedTreeView> createState() => _AnimatedTreeViewState();
}

class _AnimatedTreeViewState extends State<AnimatedTreeView> {
  late final TreeController<Node> treeController;
  late final Node root = Node(title: 'A portion of the world');

  @override
  void initState() {
    super.initState();
    generateTreeNodes(root, (Node parent, String title) {
      final child = Node(title: title);
      parent.children.add(child);
      return child;
    });

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: (Node node) => node.children,
    );
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAnimatedTree<Node>(
          treeController: treeController,
          duration: Durations.long2,
          nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
            return TreeIndentation(
              entry: entry,
              child: Row(
                children: [
                  FolderButton(
                    key: Key('FolderButton#${entry.node.title}'),
                    isOpen: entry.isExpanded,
                    onPressed: () => treeController.toggleExpansion(entry.node),
                  ),
                  Flexible(child: Text(entry.node.title)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class SliverAnimatedTree<T extends Object> extends StatefulWidget {
  const SliverAnimatedTree({
    super.key,
    required this.treeController,
    required this.nodeBuilder,
    this.duration = Durations.medium2,
    this.transitionBuilder = defaultTreeTransitionBuilder,
  });

  final TreeController<T> treeController;
  final TreeNodeBuilder<T> nodeBuilder;
  final Duration duration;
  final TreeTransitionBuilder transitionBuilder;

  @override
  State<SliverAnimatedTree<T>> createState() => _SliverAnimatedTreeState<T>();
}

class _SliverAnimatedTreeState<T extends Object>
    extends State<SliverAnimatedTree<T>> {
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();

  late Map<T, TreeEntry<T>> _nodeToEntry = <T, TreeEntry<T>>{};
  List<TreeEntry<T>> _flatTree = const [];

  void _createFlatTree() {
    final Map<T, TreeEntry<T>> newEntries = <T, TreeEntry<T>>{};
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];

    widget.treeController.depthFirstTraversal(onTraverse: (TreeEntry<T> entry) {
      flatTree.add(entry);
      newEntries[entry.node] = entry;
    });

    _flatTree = flatTree;
    _nodeToEntry = newEntries;
  }

  void _updateFlatTree() {
    if (widget.duration == Duration.zero) {
      setState(_createFlatTree);
      return;
    }

    final Map<T, TreeEntry<T>> oldEntries = <T, TreeEntry<T>>{..._nodeToEntry};
    final Map<T, TreeEntry<T>> newEntries = <T, TreeEntry<T>>{};
    final List<int> indicesAnimatingIn = <int>[];
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];

    widget.treeController.depthFirstTraversal(onTraverse: (TreeEntry<T> entry) {
      flatTree.add(entry);
      newEntries[entry.node] = entry;

      if (oldEntries.remove(entry.node) == null) {
        indicesAnimatingIn.add(entry.index);
      }
    });

    for (final TreeEntry<T> entry in oldEntries.values.toList().reversed) {
      _listKey.currentState?.removeItem(
        duration: widget.duration,
        entry.index,
        (BuildContext context, Animation<double> animation) {
          return widget.transitionBuilder(
            context,
            widget.nodeBuilder(context, entry),
            animation,
          );
        },
      );
    }

    setState(() {
      _flatTree = flatTree;
      _nodeToEntry = newEntries;
    });

    for (final int index in indicesAnimatingIn) {
      _listKey.currentState?.insertItem(index, duration: widget.duration);
    }
  }

  void _rebuild() => _updateFlatTree();

  @override
  void initState() {
    super.initState();
    widget.treeController.addListener(_rebuild);
    _createFlatTree();
  }

  @override
  void dispose() {
    _flatTree = const [];
    _nodeToEntry = const {};
    widget.treeController.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _flatTree.length,
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        return widget.transitionBuilder(
          context,
          widget.nodeBuilder(context, _flatTree[index]),
          animation,
        );
      },
    );
  }
}
