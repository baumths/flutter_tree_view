import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/foundation.dart' show binarySearch;
import 'package:flutter/material.dart';

import 'tree_node.dart';
import 'tree_node_scope.dart';
import 'tree_view_theme.dart';
import 'utils.dart' show subtreeGenerator;

/// Callback to build a widget for [TreeNode].
typedef NodeBuilder = Widget Function(BuildContext context, TreeNode node);

/// A simple, fancy and highly customizable hierarchy visualization Widget.
///
/// Use a [GlobalKey<TreeViewState>] to toggle nodes from outside of the
/// [TreeView] widget tree.
///
/// [TreeView.of] can be called to toggle nodes within the context of [TreeView].
class TreeView extends StatefulWidget {
  /// Creates a [TreeView].
  ///
  /// Take a look at [NodeWidget] for your [nodeBuilder].
  const TreeView({
    Key? key,
    required this.nodeBuilder,
    required this.rootNode,
    this.theme = const TreeViewTheme(),
    this.nodeHeight = 40.0,
    this.shrinkWrap = false,
    this.useBinarySearch = false,
    this.shouldAutoScroll = true,
    this.onAboutToExpand,
    this.padding,
    this.scrollController,
  }) : super(key: key);

  /// The [TreeNode] that will store all top level nodes.
  ///
  /// This node doesn't get displayed in the [TreeView],
  /// it is only used to index/find nodes easily.
  final TreeNode rootNode;

  /// The instance of [TreeViewTheme] that controls the theme of the [TreeView].
  final TreeViewTheme theme;

  /// The space around the [ListView] that holds the [TreeNode]s.
  final EdgeInsetsGeometry? padding;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// See [ListView.shrinkWrap].
  final bool shrinkWrap;

  /// Called, as needed, to build node widgets.
  /// Nodes are only built when they're scrolled into view.
  ///
  /// If you are using your own widget, make sure to add the indentation to it
  /// using [TreeNodeScope.indentation]. Example:
  ///
  /// ```dart
  /// /* Using Padding: */
  /// @override
  /// Widget build(BuildContext context) {
  ///   final treeNodeScope = TreeNodeScope.of(context);
  ///   return Padding(
  ///     padding: EdgeInsets.only(left: treeNodeScope.indentation),
  ///     child: MyCustomNodeWidget(/* [...] */),
  ///   );
  /// }
  /// /* Using LinesWidget: */
  /// @override
  /// Widget build(BuildContext context) {
  ///   /* This allows the addition of custom Widgets
  ///      at the beginning of each node, like a custom color or button.*/
  ///   return Row(
  ///     children: [
  ///       const LinesWidget(),
  ///
  ///       /* add some spacing in between */
  ///       const SizedBox(width: 16),
  ///
  ///       /* The content (title, description) */
  ///       MyNodeLabel(/* [...] */),
  ///
  ///       /* Align the ExpandNodeIcon to the end */
  ///       const Spacer(),
  ///
  ///       /* A button to expand/collapse nodes */
  ///       const ExpandNodeIcon(),
  ///     ],
  ///   );
  /// }
  /// ```
  final NodeBuilder nodeBuilder;

  /// The height each node will take, its more efficient (for the scrolling
  /// machinery) than letting the nodes determine their own height. (Also used
  /// by [ScrollController] to determine the offset of a node and scroll to it).
  ///
  /// Defaults to `40.0`.
  final double nodeHeight;

  /// Whether [TreeViewState.indexOf] should use flutter's [binarySearch]
  /// instead of [List.indexOf] when looking for the index of a node.
  ///
  /// The binary search will compare the [TreeNode.id] of two nodes. So if you
  /// enable this, make sure that [TreeNode.id] is
  /// [ASCII](http://www.asciitable.com/) formatted and sorted.
  ///
  /// Defaults to `false`.
  final bool useBinarySearch;

  /// Enables auto scrolling to node when it is expanded/collapsed.
  ///
  /// Defaults to `true`.
  final bool shouldAutoScroll;

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

  /// The [ScrollController] responsible for scrolling nodes into view when
  /// expanded/collapsed.
  final ScrollController? scrollController;

  /// Returns the current state of the [TreeView].
  static TreeViewState of(BuildContext context) {
    final treeViewScope =
        context.dependOnInheritedWidgetOfExactType<_TreeViewScope>();

    assert(() {
      if (treeViewScope != null) return true;
      throw Exception('No _TreeViewScope was found in the given context.');
    }());

    return treeViewScope!._treeViewState;
  }

  @override
  TreeViewState createState() => TreeViewState();
}

/// Controls the state of the [TreeView].
///
/// Use either [GlobalKey<TreeViewState>] when creating the [TreeView] or call
/// [TreeView.of] if the current context is within the [TreeView]'s widget tree.
///
/// From this State object you are able to dynamically operate on nodes.
class TreeViewState extends State<TreeView> {
  late final _expandedNodes = <String, bool>{};
  late final _visibleNodesMap = <String, bool>{};

  /// Cache to avoid searching multiple times for the same node.
  late final _searchedNodesCache = <String, TreeNode>{};

  final _visibleNodes = <TreeNode>[];

  /// The list of [TreeNode]'s that are currently visible in the [TreeView].
  UnmodifiableListView<TreeNode> get visibleNodes {
    return UnmodifiableListView(_visibleNodes);
  }

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _populateVisibleNodes();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(covariant TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    assert(() {
      if (widget.rootNode.isRoot) return true;
      throw Exception("The rootNode's parent must be null.");
    }());

    if (oldWidget.rootNode != widget.rootNode) {
      _populateVisibleNodes();
    }
    if (oldWidget.scrollController != widget.scrollController) {
      _scrollController = widget.scrollController ?? ScrollController();
    }
  }

  @override
  void dispose() {
    if (_scrollController != widget.scrollController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  /// Verifies if the [TreeNode] with [id] is expanded.
  bool isExpanded(String id) => _expandedNodes[id] ?? false;

  /// Verifies if the [TreeNode] with [id] is visible.
  bool isVisible(String id) => _visibleNodesMap[id] ?? false;

  /// Returns the node at [index] of [visibleNodes].
  TreeNode nodeAt(int index) => _visibleNodes[index];

  /// Returns the index of [node] in [TreeViewState.visibleNodes],
  /// `-1` if not present.
  ///
  /// Take a look at [TreeView.useBinarySearch] if your [TreeNode.id]'s are
  /// [ASCII](http://www.asciitable.com/) formatted and sorted.
  int indexOf(TreeNode node) {
    if (widget.useBinarySearch) {
      return binarySearch(_visibleNodes, node);
    }
    return _visibleNodes.indexOf(node);
  }

  /// Starting from [TreeView.rootNode], searches the subtree looking for a node
  /// id that match [id], returns `null` if no node was found with the given [id].
  TreeNode? find(String id) {
    final cachedNode = _searchedNodesCache[id];

    if (cachedNode != null) {
      return cachedNode;
    }

    final searchedNode = widget.rootNode.find(id);

    if (searchedNode != null) {
      _searchedNodesCache[searchedNode.id] = searchedNode;
    }

    return searchedNode;
  }

  /// Scrolls [node] into view.
  ///
  /// If [node]'s parent is collapsed, the offset will be negative resulting in
  /// scrolling to the start of the [TreeView].
  void scrollTo(TreeNode node) {
    if (!widget.shouldAutoScroll) return;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final offset = indexOf(node) * widget.nodeHeight;

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    });
  }

  /// Expands [node].
  ///
  /// If the ancestors of [node] are collapsed, it will expand them too.
  void expandNode(TreeNode node) {
    setState(() => _expandNode(node));
    scrollTo(node);
  }

  /// Expands [node] and every descendant node.
  void expandSubtree(TreeNode node) {
    setState(() => _expandSubtree(node));
    scrollTo(node);
  }

  /// Expands every node within the path from root to [node].
  ///
  /// _Does not expand [node]._
  void expandUntil(TreeNode node) {
    setState(() => _expandUntil(node));
    scrollTo(node);
  }

  /// Collapses [node] and it's subtree.
  void collapseNode(TreeNode node) {
    setState(() => _collapseNode(node));
  }

  /// Expands every node in the tree.
  void expandAll() => expandSubtree(widget.rootNode);

  /// Collapses all nodes.
  ///
  /// Only the children of [TreeView.rootNode] will be visible.
  void collapseAll() {
    setState(() {
      widget.rootNode.children.forEach(_collapseNode);
    });
  }

  /// Toggles the expansion of [node] to the opposite state.
  void toggleExpanded(TreeNode node) {
    isExpanded(node.id) ? collapseNode(node) : expandNode(node);
  }

  @override
  Widget build(BuildContext context) {
    return _TreeViewScope(
      treeViewState: this,
      child: ListView.custom(
        controller: _scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.nodeHeight,
        childrenDelegate: SliverChildBuilderDelegate(
          _nodeBuilder,
          childCount: _visibleNodes.length,
          findChildIndexCallback: (Key key) {
            final index = indexOf((key as ValueKey<TreeNode>).value);
            return index < 0 ? null : index;
          },
        ),
      ),
    );
  }

  Widget _nodeBuilder(BuildContext context, int index) {
    final node = nodeAt(index);

    return TreeNodeScope(
      key: ValueKey<TreeNode>(node),
      node: node,
      theme: widget.theme,
      isExpanded: isExpanded(node.id),
      child: widget.nodeBuilder(context, node),
    );
  }

  void _populateVisibleNodes() {
    _visibleNodes.clear();
    _visibleNodesMap.clear();
    _expandedNodes.clear();

    widget.rootNode.children.forEach((child) {
      _visibleNodes.add(child);
      _visibleNodesMap[child.id] = true;
    });

    _expandedNodes[widget.rootNode.id] = true;
  }

  /* 
    * The following methods are private to manipulate [_visibleNodes] without
    * calling [setState] on each operation. They are the core of this widget.
  */

  void _expandNode(TreeNode node) {
    if (node.isRoot || isExpanded(node.id)) return;

    // Expand all ancestors of [node] if its parent is not expanded.
    if (!isExpanded(node.parent!.id)) _expandUntil(node);

    widget.onAboutToExpand?.call(node);

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

  void _collapseNode(TreeNode node) {
    if (!isExpanded(node.id)) return;

    if (!node.isRoot) {
      _expandedNodes.remove(node.id);
    }

    subtreeGenerator(node).forEach((descendant) {
      if (descendant.isRemovable && isVisible(descendant.id)) {
        _expandedNodes.remove(descendant.id);
        _visibleNodes.remove(descendant);
        _visibleNodesMap.remove(descendant.id);
      }
    });
  }

  void _expandSubtree(TreeNode node) {
    _expandNode(node);
    node.children.forEach(_expandSubtree);
  }

  void _expandUntil(TreeNode node) {
    node.ancestors.forEach(_expandNode);
  }
}

/// A simple [InheritedWidget] to get the current [TreeViewState] from anywhere
/// in the widget tree below [TreeView].
class _TreeViewScope extends InheritedWidget {
  const _TreeViewScope({
    Key? key,
    required TreeViewState treeViewState,
    required Widget child,
  })   : _treeViewState = treeViewState,
        super(key: key, child: child);

  final TreeViewState _treeViewState;

  @override
  bool updateShouldNotify(_TreeViewScope oldWidget) => false;
}
