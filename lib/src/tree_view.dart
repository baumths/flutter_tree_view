import 'internal.dart';

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
    this.theme = const TreeViewTheme(),
  }) : super(key: key);

  /// The instance of [TreeController] to control nodes from outside of
  /// the [TreeView] widget subtree.
  final TreeViewController controller;

  /// The instance of [TreeViewTheme] that controls the theme of the [TreeView].
  final TreeViewTheme theme;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// See [AnimatedList.shrinkWrap]
  final bool shrinkWrap;

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
  ///       LinesWidget(
  ///         node: treeNode,
  ///         theme: treeViewTheme,
  ///       ),
  ///       /* add some spacing in between */
  ///       const SizedBox(width: 16),
  ///
  ///       /* The content (title, description) */
  ///       MyCustomNodeWidget(/* [...] */),
  ///
  ///       /* A button to expand/collapse nodes */
  ///       ExpandNodeIcon(
  ///         node: treeNode,
  ///         onToggle: () => print(treeNode),
  ///       ),
  ///     ],
  ///   );
  /// }
  /// /* You could also use SizedBox/Container to align
  ///    the nodes to the right and indent from there. */
  /// ```
  final NodeBuilder nodeBuilder;

  @override
  _TreeViewState createState() => _TreeViewState();
}

class _TreeViewState extends State<TreeView> {
  late final TreeViewController controller;

  /// A key to control the animation of adding/removing nodes
  final _animatedListKey = GlobalKey<AnimatedListState>();
  AnimatedListState get _animatedList => _animatedListKey.currentState!;

  @override
  void initState() {
    super.initState();
    controller = widget.controller
      ..populateInitialNodes()
      ..addExpandCallback(_insertNode)
      ..addCollapseCallback(_removeNode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _animatedListKey,
      shrinkWrap: widget.shrinkWrap,
      initialItemCount: controller.visibleNodes.length,
      itemBuilder: (_, int index, Animation<double> animation) {
        final node = controller.nodeAt(index)
          ..addExpansionCallback(controller.toggleNode);
        return _buildNode(node, animation);
      },
    );
  }

  // * ~~~~~~~~~~ PRIVATE METHODS ~~~~~~~~~~ *

  /// The callback to build the widget that will get animated
  /// when a node is inserted/removed from de tree.
  Widget _buildNode(TreeNode node, Animation<double> animation) {
    return _NodeTransition(
      key: node.id == null ? UniqueKey() : ValueKey<int>(node.id!),
      animation: animation,
      child: widget.nodeBuilder(context, node),
    );
  }

  /// Animates the insertion of a new node.
  void _insertNode(int index) => _animatedList.insertItem(index);

  /// Animates the removal of a node.
  void _removeNode(int index, TreeNode node) {
    _animatedList.removeItem(
      index,
      (_, animation) => _buildNode(node, animation),
    );
  }

  @override
  void dispose() {
    controller.removeCallbacks();
    super.dispose();
  }
}

class _NodeTransition extends StatelessWidget {
  const _NodeTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
