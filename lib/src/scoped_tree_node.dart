import 'internal.dart';

/// An implementation of [InheritedWidget] to manage the state of [TreeNode]s
/// throughout the subtree of this widget.
///
/// Each [TreeNode] in the [TreeView] have its own [ScopedTreeNode] widget to
/// make it possible to update (expand / collapse) the node attached to
/// this widget from anywhere in it's subtree.
///
/// This implementation also makes it possible to have constant constructors
/// in [NodeWidget] or any widget chosen as an entry of [TreeView] to improve
/// performance as it usually doesn't need to be rebuilt when the nodes
/// around it change.
class ScopedTreeNode extends InheritedWidget {
  /// Creates an [ScopedTreeNode].
  ///
  /// This widget shouldn't be created manually, the [TreeView] already takes
  /// care of it internally. It should only be used to access [node] and [isExpanded].
  ScopedTreeNode({
    Key? key,
    required this.node,
    this.isExpanded = false,
    required Widget child,
  }) : super(key: key, child: child);

  /// Whether [ScopedTreeNode.node] is currently expanded or not.
  final bool isExpanded;

  /// The [TreeNode] provided to the widget subtree of this [ScopedTreeNode].
  final TreeNode node;

  // * ~~~~~~~~~~ EXPANSION METHODS ~~~~~~~~~~ *

  /// Notifies [TreeViewController] to expand this node.
  void expand(BuildContext context) {
    TreeView.of(context).controller.expandNode(node);
  }

  /// Notifies [TreeViewController] to collapse this node.
  void collapse(BuildContext context) {
    TreeView.of(context).controller.collapseNode(node);
  }

  /// Toggles [isExpanded] to the opposite state.
  void toggleExpanded(BuildContext context) {
    isExpanded ? collapse(context) : expand(context);
  }

  /// Finds the nearest [ScopedTreeNode] and subscribes [context] to state changes.
  static ScopedTreeNode of(BuildContext context) {
    final scopedTreeNode =
        context.dependOnInheritedWidgetOfExactType<ScopedTreeNode>();

    assert(
      scopedTreeNode != null,
      'No ScopedTreeNode was found in the given context.',
    );

    return scopedTreeNode!;
  }

  @override
  bool updateShouldNotify(ScopedTreeNode oldWidget) {
    return isExpanded != oldWidget.isExpanded || node != oldWidget.node;
  }
}
