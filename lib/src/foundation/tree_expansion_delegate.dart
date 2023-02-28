/// An interface used to delegate the operations of getting and setting the
/// expansion state of tree nodes.
///
/// Example using a property on a node object:
/// ```dart
/// class Node {
///   bool isExpanded = false;
/// }
///
/// class TreeNodeExpansionDelegate implements TreeExpansionDelegate<Node> {
///   const TreeNodeExpansionDelegate();
///
///   @override
///   bool get(Node node) => node.isExpanded;
///
///   @override
///   void set(Node node, bool expanded) {
///     node.isExpanded = expanded;
///   }
/// }
/// ```
///
/// See also:
/// * [TreeExpansionSet], which uses a [Set] to store the expansion state
///   of tree nodes.
abstract class TreeExpansionDelegate<T extends Object> {
  /// Abstract constant constructor.
  const TreeExpansionDelegate();

  /// The current expansion state of [node].
  ///
  /// If this method returns `true`, the children of [node] should be visible
  /// in tree views.
  bool get(T node);

  /// Update the expansion state of [node] to the value of [expanded].
  void set(T node, bool expanded);
}

/// A [TreeExpansionDelegate] implementation that  uses a [Set] to store the
/// expansion state of tree nodes.
///
/// Usage:
/// ```dart
/// final TreeExpansionDelegate<int> expandedIds = TreeExpansionSet<int>();
///
/// expandedIds.get(1); // false
/// expandedIds.set(1, true);
/// expandedIds.get(1); // true
/// ```
class TreeExpansionSet<T extends Object> implements TreeExpansionDelegate<T> {
  /// Creates a [TreeExpansionSet].
  ///
  /// [initiallyExpandedNodes] can be used to have some tree nodes already
  /// expanded by default.
  TreeExpansionSet({
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

  /// Removes all nodes from the expanded nodes [Set].
  void clear() => expandedNodes.clear();
}
