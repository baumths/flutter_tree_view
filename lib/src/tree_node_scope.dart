import 'package:flutter/widgets.dart';

import 'tree_node.dart';
import 'tree_view.dart';
import 'tree_view_theme.dart';

/// An implementation of [InheritedWidget] to manage the state of [TreeNode]s
/// throughout the subtree of this widget.
///
/// Each [TreeNode] in the [TreeView] have its own [TreeNodeScope] widget to
/// make it possible to update (expand / collapse) the node attached to
/// this widget from anywhere in it's subtree.
///
/// This implementation also makes it possible to have constant constructors
/// in [NodeWidget] or any widget chosen as an entry of [TreeView] to improve
/// performance as it usually doesn't need to be rebuilt when the nodes
/// around it change.
class TreeNodeScope extends InheritedWidget {
  /// Creates a [TreeNodeScope].
  ///
  /// This widget shouldn't be created manually, the [TreeView] already takes
  /// care of it internally. It should only be used to access [node] and [isExpanded].
  TreeNodeScope({
    Key? key,
    required this.node,
    required this.theme,
    this.isExpanded = false,
    required Widget child,
  }) : super(key: key, child: child);

  /// Whether [TreeNodeScope.node] is currently expanded or not.
  final bool isExpanded;

  /// The [TreeNode] provided to the widget subtree of this [TreeNodeScope].
  final TreeNode node;

  /// The instance of [TreeViewTheme] that controls the theme of the [TreeView].
  final TreeViewTheme theme;

  /// Calculates the amount of indentation of this node. `depth * [indent]`
  ///
  /// [indent] => the amount of space added per level (example below).
  ///
  /// ```
  /// /* given: indent = 20.0
  /// __________________________________
  /// |___node___                      | depth = 0, indentation =  0
  /// |          |___node___           | depth = 1, indentation = 20
  /// |           <-indent->|___node___| depth = 2, indentation = 40
  /// | <-------- indentation -------> | */
  /// ```
  double get indentation => node.depth * theme.indent;

  // * ~~~~~~~~~~ EXPANSION METHODS ~~~~~~~~~~ *

  /// Notifies [TreeViewState] to expand this node.
  void expand(BuildContext context) {
    TreeView.of(context).expandNode(node);
  }

  /// Notifies [TreeViewState] to collapse this node.
  void collapse(BuildContext context) {
    TreeView.of(context).collapseNode(node);
  }

  /// Toggles [isExpanded] to the opposite state.
  void toggleExpanded(BuildContext context) {
    isExpanded ? collapse(context) : expand(context);
  }

  /// Finds the nearest [TreeNodeScope] and subscribes [context] to state changes.
  static TreeNodeScope of(BuildContext context) {
    final treeNodeScope =
        context.dependOnInheritedWidgetOfExactType<TreeNodeScope>();

    assert(() {
      if (treeNodeScope != null) return true;
      throw Exception('No TreeNodeScope was found in the given context.');
    }());

    return treeNodeScope!;
  }

  @override
  bool updateShouldNotify(TreeNodeScope oldWidget) {
    return theme != oldWidget.theme ||
        isExpanded != oldWidget.isExpanded ||
        node != oldWidget.node;
  }
}
