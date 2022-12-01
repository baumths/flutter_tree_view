import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../pages.dart';

// This approach to lazy loading is just an example, there are many other ways
// of doing it.

class Node extends TreeNode<Node> {
  Node({required this.key, required this.label});

  @override
  final int key;

  @override
  Iterable<Node> get children => _children ?? const Iterable.empty();
  Iterable<Node>? _children;
  set children(Iterable<Node> nodes) {
    _children = nodes;
    childrenLoaded = true;
  }

  final String label;

  bool isExpanded = false;
  bool isLoading = false;
  bool childrenLoaded = false;
}

// The implementation is at the end of the file and is not important.
abstract class Repository {
  static const int rootKey = 0;
  Future<Iterable<Node>> findChildren(int parentKey);
}

class MyController extends TreeController<Node> {
  MyController({
    required this.repository,
    required this.root,
  });

  final Repository repository;
  final Node root;

  @override
  bool getExpansionState(Node node) => node.isExpanded;

  @override
  void setExpansionState(Node node, bool expanded) {
    node.isExpanded = expanded;
  }

  Future<void> loadRoots() async {
    root.children = await repository.findChildren(root.key);
  }

  Future<void> loadChildren(Node parent) async {
    if (parent.childrenLoaded) return;
    parent.children = await repository.findChildren(parent.key);
  }
}

class LazyTreeView extends StatefulWidget with PageInfo {
  const LazyTreeView({super.key});

  @override
  String get title => 'Lazy Loaded TreeView';

  @override
  State<LazyTreeView> createState() => _LazyTreeViewState();
}

// This value is used both as the height of the node tile and as the indent of
// each level of the tree.
const double indentByLevel = 32.0;

class _LazyTreeViewState extends State<LazyTreeView> {
  late final MyController treeController;

  bool isTreeLoading = true;

  Future<void> loadRootNodes() async {
    await treeController.loadRoots();
    isTreeLoading = false;

    if (!mounted) return;
    setState(() {});
  }

  Future<void> loadChildren(Node node) async {
    if (node.isLoading || node.childrenLoaded) return;

    setState(() {
      node.isLoading = true;
    });

    await treeController.loadChildren(node);
    node
      ..isLoading = false
      ..isExpanded = node.hasChildren;

    if (!mounted) return;
    setState(treeController.rebuild);
  }

  @override
  void initState() {
    super.initState();

    treeController = MyController(
      repository: RepositorySimulation(),
      root: Node(key: Repository.rootKey, label: '/'),
    );

    loadRootNodes();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isTreeLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black87),
      );
    }

    return DefaultIndentGuide(
      guide: const IndentGuide.connectingLines(indent: indentByLevel),
      child: TreeView<Node>(
        roots: treeController.root.children,
        controller: treeController,
        itemBuilder: (BuildContext context, TreeEntry<Node> entry) {
          return MyTreeItem(
            node: entry.node,
            leading: getLeadingFor(entry.node),
            onTap: getActionFor(entry.node),
          );
        },
      ),
    );
  }

  VoidCallback? getActionFor(Node node) {
    if (node.isLoading) {
      return null;
    }

    if (!node.childrenLoaded) {
      return () => loadChildren(node);
    }

    if (node.hasChildren) {
      return () => treeController.toggleExpansion(node);
    }

    return null;
  }

  Widget getLeadingFor(Node node) {
    if (node.isLoading) {
      return const SizedBox.square(
        dimension: indentByLevel / 2,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.black87,
        ),
      );
    }

    if (!node.childrenLoaded) {
      return const Icon(Icons.expand_more);
    }

    if (!node.hasChildren) {
      return const Icon(Icons.article_outlined, size: 20);
    }

    if (node.isExpanded) {
      return const Icon(Icons.expand_less);
    }

    return const Icon(Icons.expand_more);
  }
}

class MyTreeItem extends StatelessWidget {
  const MyTreeItem({
    super.key,
    required this.node,
    this.leading,
    this.onTap,
  });

  final Node node;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TreeItem(
      onTap: onTap,
      child: SizedBox(
        height: indentByLevel,
        child: Row(
          children: [
            SizedBox.square(
              dimension: indentByLevel,
              child: Center(
                child: leading,
              ),
            ),
            Flexible(
              child: Text(
                node.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Not important
class RepositorySimulation implements Repository {
  static final Random random = Random();

  static Duration get randomDuration {
    final int step = random.nextBool() ? 50 : 100;
    final int amount = random.nextInt(26) + 5;
    return Duration(milliseconds: step * amount);
  }

  @override
  Future<Iterable<Node>> findChildren(int parentKey) async {
    await Future.delayed(randomDuration);

    String prefix = 'Node';
    int max = 5, min = 0;

    if (parentKey == Repository.rootKey) {
      prefix = 'Root';
      max = 3;
      min = 2;
    }

    return [
      for (int index = 0; index <= random.nextInt(max + 1) + min; ++index)
        Node(key: ++_autoIncrement, label: '$prefix #${++_autoIncrement}'),
    ];
  }

  int _autoIncrement = 1 + Repository.rootKey;
}
