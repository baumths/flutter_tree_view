import 'internal.dart';

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
    this.shrinkWrap = false,
    this.nodeHeight = 40.0,
    this.theme = const TreeViewTheme(),
    this.padding,
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
  /// See [ListView.shrinkWrap]
  final bool shrinkWrap;

  /// The height each node will take, its more efficient (for the scrolling
  /// machinery) than letting the nodes determine their own height.
  final double nodeHeight;

  /// Called, as needed, to build node widgets.
  /// Nodes are only built when they're scrolled into view.
  ///
  /// If you are using your own widget, make sure to add the indentation to it
  /// using [TreeNode.calculateIndentation] with the amount of indent defined
  /// in [TreeViewTheme.indent] for consistency. Example:
  ///
  /// ```dart
  /// /* Using Padding: */
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Padding(
  ///     padding: EdgeInsets.only(
  ///       left: treeNode.calculateIndentation(treeViewTheme.indent),
  ///     ),
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
  ///       MyCustomNodeWidget(/* [...] */),
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

  /// Calls `context.dependOnInheritedWidgetOfExactType<InheritedTreeView>()`
  /// subscribing [context] to changes in [InheritedTreeView].
  ///
  /// Mostly used to get the instances of [TreeViewController] and
  /// [TreeViewTheme] currently being used by the [TreeView].
  static InheritedTreeView of(BuildContext context) {
    final inheritedTreeView =
        context.dependOnInheritedWidgetOfExactType<InheritedTreeView>();

    assert(
      inheritedTreeView != null,
      'No InheritedTreeView was found in the given context.',
    );

    return inheritedTreeView!;
  }

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  TreeViewController get controller => widget.controller;

  void _update() => setState(() {});

  @override
  void initState() {
    super.initState();
    controller.addListener(_update);
  }

  @override
  void didUpdateWidget(covariant TreeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(_update);
      controller.addListener(_update);
    }
  }

  @override
  void dispose() {
    controller.removeListener(_update);
    super.dispose();
  }

  Widget nodeBuilder(BuildContext context, int index) {
    final node = controller.nodeAt(index);

    return ScopedTreeNode(
      key: ValueKey<TreeNode>(node),
      node: node,
      isExpanded: controller.isExpanded(node.id),
      child: widget.nodeBuilder(context, node),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InheritedTreeView(
      theme: widget.theme,
      controller: controller,
      child: ListView.custom(
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        itemExtent: widget.nodeHeight,
        childrenDelegate: SliverChildBuilderDelegate(
          nodeBuilder,
          childCount: controller.visibleNodes.length,
          findChildIndexCallback: (Key key) {
            final index = controller.indexOf(
              (key as ValueKey<TreeNode>).value,
            );
            return index < 0 ? null : index;
          },
        ),
      ),
    );
  }
}

/// A simple [InheritedWidget] to get [TreeViewTheme] and [TreeViewController]
/// from anywhere in the widget tree below [TreeView].
class InheritedTreeView extends InheritedWidget {
  /// Creates an [InheritedTreeView].
  const InheritedTreeView({
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
  bool updateShouldNotify(InheritedTreeView oldWidget) {
    return theme != oldWidget.theme || controller != oldWidget.controller;
  }
}
