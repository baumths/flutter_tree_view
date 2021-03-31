import 'internal.dart';

/// A simple Controller for managing the nodes that compose [TreeView].
///
/// This class was extracted from [TreeView] for use cases where you
/// need to toggle/find a node from above of [TreeView] in the widget tree.
///
/// This controller should have at most 1 listener (the [TreeView] itself) that
/// removes itself when disposed, but you might as well call
/// `dispose` just to be safe, as this is a [ChangeNotifier] after all.
class TreeViewController extends TreeViewControllerBase with ChangeNotifier {
  /// Creates a [TreeViewController].
  TreeViewController({
    required TreeNode rootNode,
  })   : assert(rootNode.isRoot, "The rootNode's parent must be null."),
        super(rootNode: rootNode);

  /// Cache to avoid searching multiple times for the same node.
  late final _searchedNodesCache = <String, TreeNode>{};

  /// Starting from [TreeViewController.rootNode], searches the subtree
  /// looking for a node id that match [id],
  /// returns `null` if no node was found with the given [id].
  TreeNode? find(String id) {
    final cachedNode = _searchedNodesCache[id];

    if (cachedNode != null) {
      return cachedNode;
    }

    final searchedNode = rootNode.find(id);

    if (searchedNode != null) {
      _searchedNodesCache[searchedNode.id] = searchedNode;
    }

    return searchedNode;
  }

  // * ~~~~~~~~~~ EXPAND/COLLAPSE METHODS ~~~~~~~~~~ *

  /// Expands [node].
  ///
  /// If the ancestors of [node] are collapsed, it will expand them too.
  @override
  void expandNode(TreeNode node) {
    super.expandNode(node);
    notifyListeners();
  }

  /// Expands [node] and every descendant node.
  @override
  void expandSubtree(TreeNode node) {
    super.expandSubtree(node);
    notifyListeners();
  }

  /// Expands every node within the path from root to [node].
  ///
  /// _Does not expand [node]._
  @override
  void expandUntil(TreeNode node) {
    super.expandUntil(node);
    notifyListeners();
  }

  /// Collapses [node] and it's subtree.
  @override
  void collapseNode(TreeNode node) {
    super.collapseNode(node);
    notifyListeners();
  }

  /// Expands every node in the tree.
  void expandAll() => expandSubtree(rootNode);

  /// Collapses all nodes.
  /// Only the children of [TreeViewController.rootNode] will be visible.
  void collapseAll() {
    rootNode.children.forEach(super.collapseNode);
    notifyListeners();
  }

  /// Toggles the expansion of [node] to the opposite state.
  @override
  void toggleExpanded(TreeNode node) {
    super.toggleExpanded(node);
    notifyListeners();
  }
}

/// Base implementation of [TreeViewController].
///
/// This class is used to make state changes without notifying listeners.
/// (improves performance™ when working with a large set of nodes).
///
/// Also enables testing of individual methods.
class TreeViewControllerBase {
  /// Creates a [TreeViewControllerBase] and populates the initial nodes.
  TreeViewControllerBase({required this.rootNode}) {
    _visibleNodes.addAll(rootNode.children);

    _expandedNodes[rootNode.id] = true;
  }

  final _expandedNodes = <String, bool>{};

  /// The [TreeNode] that will store all top level nodes.
  ///
  /// This node doesn't get displayed in the [TreeView],
  /// it is only used to index/find nodes easily.
  final TreeNode rootNode;

  /// The list of [TreeNode]s that are currently visible in the [TreeView].
  List<TreeNode> get visibleNodes => _visibleNodes;
  final _visibleNodes = <TreeNode>[];

  // * ~~~~~~~~~~ HELPER METHODS ~~~~~~~~~~ *

  /// Verifies if the [TreeNode] with [id] is expanded.
  bool isExpanded(String id) => _expandedNodes[id] ?? false;

  /// Returns the node at [index] of [visibleNodes].
  TreeNode nodeAt(int index) => _visibleNodes[index];

  int _indexOf(TreeNode node) => _visibleNodes.indexOf(node);

  /// Expands [node] if it is not expanded.
  ///
  /// If the path from root to [node] has collapsed nodes, it will expand them too.
  @mustCallSuper
  void expandNode(TreeNode node) {
    if (node.isRoot || isExpanded(node.id)) return;

    // Expand all ancestors of [node] if its parent is not expanded.
    if (!isExpanded(node.parent!.id)) expandUntil(node);

    if (node.hasChildren) {
      _expandedNodes[node.id] = true;

      // The list must be reversed for the order to not get messed up
      node.children.reversed
          .where((child) => !_visibleNodes.contains(child))
          .forEach(
            (child) => _visibleNodes.insert(_indexOf(node) + 1, child),
          );
    }
  }

  /// Collapses [node] and every descendant in its subtree.
  @mustCallSuper
  void collapseNode(TreeNode node) {
    if (node.isLeaf || !isExpanded(node.id)) return;

    if (!node.isRoot) {
      _expandedNodes.remove(node.id);
    }

    reversedSubtreeGenerator(node).where((descendant) {
      return descendant.isRemovable && _visibleNodes.contains(descendant);
    }).forEach((descendant) {
      _expandedNodes.remove(descendant.id);
      _visibleNodes.remove(descendant);
    });
  }

  /// Toggles the state of [node] to its opposite.
  @mustCallSuper
  void toggleExpanded(TreeNode node) {
    isExpanded(node.id) ? collapseNode(node) : expandNode(node);
  }

  /// Expands every descendant of [node].
  @mustCallSuper
  void expandSubtree(TreeNode node) {
    expandNode(node);
    node.children.forEach(expandSubtree);
  }

  /// Expands every ascendant of [node], but not [node] itself.
  @mustCallSuper
  void expandUntil(TreeNode node) {
    node.ancestors.forEach(expandNode);
  }
}
