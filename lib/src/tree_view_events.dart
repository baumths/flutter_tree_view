import 'internal.dart';

class TreeViewEventDispatcher with ChangeNotifier {
  TreeViewEventDispatcher();

  TreeViewEvent _event = const TreeViewStartedEvent();

  /// The most recent event dispatched
  TreeViewEvent get event => _event;

  /// Overrides the last event.
  void emit(TreeViewEvent event) {
    _event = event;
    notifyListeners();
  }
}

/// An interface for collapsing/expanding nodes Events
abstract class TreeViewEvent {
  const TreeViewEvent();
}

/// Initial event to avoid null events
class TreeViewStartedEvent implements TreeViewEvent {
  const TreeViewStartedEvent();
}

/// Event dispatched when a node is expanded.
class NodeExpandedEvent implements TreeViewEvent {
  const NodeExpandedEvent({required this.node});

  /// The node to be expanded
  final TreeNode node;
}

/// Event dispatched when a node is collapsed
class NodeCollapsedEvent implements TreeViewEvent {
  const NodeCollapsedEvent({required this.nodes});

  /// The nodes to be collapsed.
  final List<TreeNode> nodes;
}
