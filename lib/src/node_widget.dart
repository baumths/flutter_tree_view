import 'internal.dart';

/// A Simple widget to display [TreeNode]s in the [TreeView].
///
/// Includes the indentation of nodes, the addition of Lines (if applicable) and
/// the leading [NodeWidgetLeadingIcon] that already expands/collapses the
/// node and animates itself.
///
/// This widget will be wrapped in a [ScopedTreeNode] (an inherited widget) to
/// give access to it's [TreeNode].
///
/// Take a look at the [online demo](https://mbaumgartenbr.github.io/flutter_tree_view).
class NodeWidget extends StatelessWidget {
  /// Creates a [NodeWidget].
  ///
  /// Notice that the [leading] [NodeWidgetLeadingIcon] used is responsible for
  /// expanding/collapsing the node, if changed, the node would need to be
  /// manually toggled through either [TreeViewController] or [ScopedTreeNode].
  ///
  /// Take a look at [ExpandNodeIcon] that has a similar implementation.
  const NodeWidget({
    Key? key,
    this.content,
    this.rowMainAxisSize = MainAxisSize.min,
    this.leading = const NodeWidgetLeadingIcon(),
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  /// A list of widgets to display to the right of [leading].
  ///
  /// This list will be added to the children of a [Row] widget.
  ///
  /// If left null, a [Text] widget with [TreeNode.label] will be used instead.
  final List<Widget>? content;

  /// The widget used to expand/collapse nodes.
  ///
  /// Defaults to [NodeWidgetLeadingIcon].
  ///
  /// Take a look at [ExpandNodeIcon] as an alternative leading.
  final Widget leading;

  /// The [Row.mainAxisSize] defaults to `MainAxisSize.min`.
  final MainAxisSize rowMainAxisSize;

  /// Callback fired when the user taps on this [NodeWidget].
  final VoidCallback? onTap;

  /// Callback fired when the user long presses this [NodeWidget].
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scopedTreeNode = ScopedTreeNode.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        mainAxisSize: rowMainAxisSize,
        children: [
          const LinesWidget(),
          leading,
          if (content == null)
            Flexible(
              child: Text(
                scopedTreeNode.node.label,
                style: Theme.of(context).textTheme.subtitle1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ...?content,
        ],
      ),
    );
  }
}
