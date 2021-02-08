import 'internal.dart';

// TODO: Missing Documentation
class TreeView extends StatefulWidget {
  /// Creates a [TreeView].
  const TreeView({
    Key? key,
    required this.nodeBuilder,
    required this.controller,
    this.shrinkWrap = false,
    this.theme = const TreeViewTheme(),
  }) : super(key: key);

  /// The instance of [TreeController] to expand/collapse nodes.
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
    return SizeAndFadeTransition(
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
