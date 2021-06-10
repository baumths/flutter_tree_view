import 'package:flutter/material.dart';

import 'tree_node.dart';
import 'tree_node_scope.dart';
import 'tree_view_controller.dart';
import 'tree_view_theme.dart';

/// Callback to build a widget for [TreeNode].
typedef NodeBuilder = Widget Function(BuildContext context, TreeNode node);

/// A simple, fancy and highly customizable hierarchy visualization Widget.
class TreeView extends StatefulWidget {
  /// Creates a [TreeView].
  ///
  /// Take a look at [NodeWidget] for your [nodeBuilder].
  const TreeView({
    Key? key,
    required this.nodeBuilder,
    required this.controller,
    this.theme = const TreeViewTheme(),
    this.nodeHeight = 40.0,
    this.shrinkWrap = false,
    this.padding,
    this.scrollController,
  }) : super(key: key);

  /// The instance of [TreeController] to control nodes from outside of
  /// the [TreeView] widget subtree.
  final TreeViewController controller;

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

  /// The [ScrollController] passed to [ListView.controller].
  final ScrollController? scrollController;

  /// Calls `context.dependOnInheritedWidgetOfExactType<_TreeViewScope>()`
  /// subscribing [context] to changes in [_TreeViewScope].
  ///
  /// Mostly used to get the instances of [TreeViewController] and
  /// [TreeViewTheme] currently being used by the [TreeView].
  static _TreeViewScope of(BuildContext context) {
    final treeViewScope =
        context.dependOnInheritedWidgetOfExactType<_TreeViewScope>();

    assert(() {
      if (treeViewScope != null) return true;
      throw Exception('No _TreeViewScope was found in the given context.');
    }());

    return treeViewScope!;
  }

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  TreeViewController get controller => widget.controller;

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_rebuild);
      controller.addListener(_rebuild);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _TreeViewScope(
      controller: controller,
      theme: widget.theme,
      child: ListView.custom(
        controller: widget.scrollController,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.nodeHeight,
        childrenDelegate: SliverChildBuilderDelegate(
          _nodeBuilder,
          childCount: controller.visibleNodes.length,
          findChildIndexCallback: (Key key) {
            final index = controller.indexOf((key as ValueKey<TreeNode>).value);
            return index < 0 ? null : index;
          },
        ),
      ),
    );
  }

  Widget _nodeBuilder(BuildContext context, int index) {
    final node = controller.nodeAt(index);

    final shouldRefresh = controller.shouldRefresh(node.id);

    if (shouldRefresh) {
      controller.nodeRefreshed(node.id);
    }

    return TreeNodeScope(
      key: ValueKey<TreeNode>(node),
      node: node,
      theme: widget.theme,
      shouldRefresh: shouldRefresh,
      isExpanded: controller.isExpanded(node.id),
      child: widget.nodeBuilder(context, node),
    );
  }
}

/// A simple [InheritedWidget] to get [TreeViewTheme] and [TreeViewController]
/// from anywhere in the widget tree below [TreeView].
class _TreeViewScope extends InheritedWidget {
  const _TreeViewScope({
    Key? key,
    required this.theme,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  /// The current theme being used by the [TreeView].
  final TreeViewTheme theme;

  /// The current controller being used by the [TreeView].
  final TreeViewController controller;

  @override
  bool updateShouldNotify(_TreeViewScope oldWidget) {
    return theme != oldWidget.theme || controller != oldWidget.controller;
  }
}
