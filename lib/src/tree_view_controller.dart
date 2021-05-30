import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/foundation.dart';

import 'tree_node.dart';

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
  ///
  /// The [useBinarySearch] parameter determines whether
  /// [TreeViewControllerBase.indexOf] should use flutter's [binarySearch]
  /// instead of [List.indexOf] when looking for the index of a node.
  ///
  /// The binary search will compare the [TreeNode.id] of two nodes. If set to
  /// `true`, make sure that [TreeNode.id] is
  /// [ASCII](http://www.asciitable.com/) formatted otherwise this could lead
  /// to adding/removing the wrong nodes from the tree.
  TreeViewController({
    required TreeNode rootNode,
    bool useBinarySearch = false,
    this.onAboutToExpand,
  })  : assert(rootNode.isRoot, "The rootNode's parent must be null."),
        super(
          rootNode: rootNode,
          useBinarySearch: useBinarySearch,
        );

  /// This method is called right before a [TreeNode] is expanded.
  ///
  /// Allows to dynamically populate the [TreeView]. Example:
  ///
  /// ```dart
  /// final rootNode = TreeNode(id: '#root')
  ///   ..addChildren(
  ///     fetchTopLevelNodesFromDatabase(),
  ///   );
  ///
  /// final treeController = TreeController(
  ///   rootNode: rootNode,
  ///   onAboutToExpand: (TreeNode nodeAboutToExpand) {
  ///     if (nodeAboutToExpand == rootNode) {
  ///       return;
  ///     }
  ///     final List<String> childrenIds = fetchChildrenOfNodeFromDatabase(
  ///       nodeAboutToExpand.id,
  ///     );
  ///
  ///     if (childrenIds.isEmpty) {
  ///       return;
  ///     }
  ///
  ///     nodeAboutToExpand.addChildren(
  ///       childrenIds.map((String childId) {
  ///         return TreeNode(id: childId);
  ///       }),
  ///     );
  ///   },
  /// );
  /// ```
  /// No checks are done to [node] before calling this method, i.e. [isExpanded].
  final void Function(TreeNode node)? onAboutToExpand;

  /// Cache to avoid searching multiple times for the same node.
  late final _searchedNodesCache = <String, TreeNode>{};

  /// Starting from [rootNode], searches the subtree looking for a node id that
  /// match [id], returns `null` if no node was found with the given [id].
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
    onAboutToExpand?.call(node);

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
  TreeViewControllerBase({
    required this.rootNode,
    this.useBinarySearch = false,
  }) {
    _visibleNodes.clear();
    _visibleNodesMap.clear();
    _expandedNodes.clear();

    rootNode.children.forEach((child) {
      _visibleNodes.add(child);
      _visibleNodesMap[child.id] = true;
    });

    _expandedNodes[rootNode.id] = true;
  }

  /// Whether [TreeViewControllerBase.indexOf] should use flutter's [binarySearch]
  /// instead of [List.indexOf] when looking for the index of a node.
  ///
  /// The binary search will compare the [TreeNode.id] of two nodes. So if you
  /// enable this, make sure that [TreeNode.id] is
  /// [ASCII](http://www.asciitable.com/) formatted.
  final bool useBinarySearch;

  late final _expandedNodes = <String, bool>{};

  /// The list of node id's that are currently expanded in the [TreeView].
  UnmodifiableListView<String> get expandedNodes {
    return UnmodifiableListView(_expandedNodes.keys);
  }

  late final _visibleNodesMap = <String, bool>{};

  /// The [TreeNode] that will store all top level nodes.
  ///
  /// This node doesn't get displayed in the [TreeView],
  /// it is only used to index/find nodes easily.
  final TreeNode rootNode;

  final _visibleNodes = <TreeNode>[];

  /// The list of [TreeNode]'s that are currently visible in the [TreeView].
  UnmodifiableListView<TreeNode> get visibleNodes {
    return UnmodifiableListView(_visibleNodes);
  }

  // * ~~~~~~~~~~ HELPER METHODS ~~~~~~~~~~ *

  /// Verifies if the [TreeNode] with [id] is expanded.
  bool isExpanded(String id) => _expandedNodes[id] ?? false;

  /// Verifies if the [TreeNode] with [id] is visible.
  bool isVisible(String id) => _visibleNodesMap[id] ?? false;

  /// Returns the node at [index] of [visibleNodes].
  TreeNode nodeAt(int index) => _visibleNodes[index];

  /// Returns the index of [node] in [TreeViewControllerBase.visibleNodes],
  /// `-1` if not present.
  ///
  /// Take a look at [TreeViewControllerBase.useBinarySearch] if your
  /// [TreeNode.id]'s are [ASCII](http://www.asciitable.com/)
  /// formatted and sorted.
  int indexOf(TreeNode node) {
    if (useBinarySearch) {
      return binarySearch(_visibleNodes, node);
    }
    return _visibleNodes.indexOf(node);
  }

  /// Expands [node] if it is not expanded.
  ///
  /// If the path from root to [node] has collapsed nodes, it will expand them too.
  @mustCallSuper
  void expandNode(TreeNode node) {
    if (node.isRoot || isExpanded(node.id)) return;

    // Expand all ancestors of [node] if its parent is not expanded.
    if (!isExpanded(node.parent!.id)) expandUntil(node);

    _expandedNodes[node.id] = true;

    if (node.hasChildren) {
      var index = indexOf(node);

      node.children.forEach((child) {
        if (isVisible(child.id)) return;

        index++;

        _visibleNodes.insert(index, child);
        _visibleNodesMap[child.id] = true;
      });
    }
  }

  /// Collapses [node] and every descendant in its subtree.
  @mustCallSuper
  void collapseNode(TreeNode node) {
    if (!isExpanded(node.id)) return;

    if (!node.isRoot) {
      _expandedNodes.remove(node.id);
    }

    node.descendants.forEach((descendant) {
      if (descendant.isRemovable && isVisible(descendant.id)) {
        _expandedNodes.remove(descendant.id);
        _visibleNodes.remove(descendant);
        _visibleNodesMap.remove(descendant.id);
      }
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
