/// An interface used to define the contract to store the expansion state of
/// tree nodes.
///
/// Example using a property on a object:
/// ```dart
/// class Node {
///   bool isExpanded = false;
/// }
///
/// class TreeNodeExpansionState implements TreeExpansionState<Node> {
///   const TreeNodeExpansionState();
///
///   @override
///   bool get(Node node) => node.isExpanded;
///
///   @override
///   void set(Node node, bool expanded) => node.isExpanded = expanded;
/// }
/// ```
///
/// See also:
/// * [TreeExpansionStateSet], which uses a [Set] to store the expansion state
///   of tree nodes.
abstract class TreeExpansionState<T extends Object> {
  /// Abstract constant constructor.
  const TreeExpansionState();

  /// The current expansion state of [node].
  ///
  /// If this method returns `true`, the children of [node] should be visible
  /// in tree views.
  bool get(T node);

  /// Update the expansion state of [node] to the value of [expanded].
  void set(T node, bool expanded);
}

/// A [TreeExpansionState] implementation that  uses a [Set] to store the
/// expansion state of tree nodes.
///
/// Usage:
/// ```dart
/// const int id = 1;
/// final TreeExpansionState<int> expandedIds = TreeExpansionStateSet<int>();
///
/// expandedIds.get(id); // false
/// expandedIds.set(id, true);
/// expandedIds.get(id); // true
/// ```
class TreeExpansionStateSet<T extends Object> implements TreeExpansionState<T> {
  /// Creates a [TreeExpansionStateSet].
  ///
  /// [initiallyExpandedNodes] can be used to have some tree nodes already
  /// expanded by default.
  TreeExpansionStateSet({
    Iterable<T>? initiallyExpandedNodes,
  }) : expandedNodes = <T>{...?initiallyExpandedNodes};

  /// The set of nodes that are currently expanded.
  final Set<T> expandedNodes;

  @override
  bool get(T node) => expandedNodes.contains(node);

  @override
  void set(T node, bool expanded) {
    expanded ? expandedNodes.add(node) : expandedNodes.remove(node);
  }
}
