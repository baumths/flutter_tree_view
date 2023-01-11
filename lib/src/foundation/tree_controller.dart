import 'package:flutter/foundation.dart' show ChangeNotifier, protected;

import 'tree_flattening.dart';
import 'typedefs.dart' show ChildrenProvider, ParentProvider, Visitor;

/// A controller that can be used to dynamically update the state of a tree.
///
/// Whenever this controller notifies its listeners any attached [SliverTree]s
/// will assume that the tree structure changed in some way and will rebuild
/// their internal flat representaton of the tree, showing/hiding the updated
/// nodes (if any).
///
/// The default implementations of [getExpansionState], [onCollapse] and
/// [onExpand] use a [Set] to store the expansion state of nodes. This
/// behavior can be changed by extending this class. In the following example
/// each node holds its own expansion state:
///
/// ```dart
/// class MyNode {
///   bool isExpanded = false;
/// }
///
/// class MyController extends TreeController<MyNode> {
///   @override
///   void onCollapse(MyNode node) => node.isExpanded = false;
///
///   @override
///   void onExpand(MyNode node) => node.isExpanded = true;
///
///   @override
///   bool getExpansionState(MyNode node) => node.isExpanded;
/// }
/// ```
class TreeController<T extends Object> with TreeFlattener<T>, ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// [roots] the nodes that will originate the tree hierarchy.
  ///
  /// [initiallyExpandedNodes] can be provided to have some nodes already
  /// expanded by default.
  TreeController({
    required Iterable<T> roots,
    required this.childrenProvider,
    Set<T>? initiallyExpandedNodes,
  }) : _roots = roots {
    if (initiallyExpandedNodes == null) return;
    expandedNodes.addAll(initiallyExpandedNodes);
  }

  /// The roots of the tree.
  ///
  /// These nodes are used as a starting point to build the flat representation
  /// of the tree.
  @override
  Iterable<T> get roots => _roots;
  Iterable<T> _roots;
  set roots(Iterable<T> nodes) {
    _roots = nodes;
    rebuild();
  }

  /// A callback that must provide the children of a given node.
  ///
  /// This callback will be used to build the flat representation of the tree.
  ///
  /// Avoid doing heavy computations in this callback since it is going to be
  /// called a lot during tree flattening.
  ///
  /// Consider calling [rebuild] when updating this property.
  @override
  ChildrenProvider<T> childrenProvider;

  /// The set of nodes that are currently expanded.
  ///
  /// This implies that the default implementations of [onCollapse] and
  /// [onExpand] weren't overriden. Otherwise, will just return a new
  /// empty set.
  @protected
  Set<T> get expandedNodes => _expandedNodes ??= <T>{};
  Set<T>? _expandedNodes;
  set expandedNodes(Set<T> nodes) {
    _expandedNodes = nodes;
    rebuild();
  }

  /// Must update the expansion state of [node] to `false`.
  ///
  /// This method can be overriden by subclasses that want to store/manipulate
  /// the expansion state of tree nodes in a different way.
  /// When overriding this method, both [onExpand] and [getExpansionState]
  /// should also be overriden.
  ///
  /// By default, this method attempts to remove [node] from the [Set] of
  /// expanded nodes.
  ///
  /// Avoid calling `notifyListeners` in this method as it may be called
  /// recursively on "cascading" operations.
  @protected
  void onCollapse(T node) => expandedNodes.remove(node);

  /// Must update the expansion state of [node] to `true`.
  ///
  /// This method can be overriden by subclasses that want to store/manipulate
  /// the expansion state of tree nodes in a different way.
  /// When overriding this method, both [onCollapse] and [getExpansionState]
  /// should also be overriden.
  ///
  /// By default, this method attempts to add [node] to the [Set] of expanded
  /// nodes.
  ///
  /// Avoid calling `notifyListeners` in this method as it may be called
  /// recursively on "cascading" operations.
  @protected
  void onExpand(T node) => expandedNodes.add(node);

  /// The current expansion state of [node].
  ///
  /// If this method returns `true`, the children of [node] should be visible
  /// in tree views.
  ///
  /// This method can be overriden by subclasses that want to store/manipulate
  /// the expansion state of tree nodes in a different way.
  /// When overriding this method, both [onCollapse] and [onExpand] should also
  /// be overriden.
  ///
  /// By default, this method checks if the expanded nodes [Set] contains [node].
  @override
  bool getExpansionState(T node) => expandedNodes.contains(node);

  /// Updates the expansion state of [node] to the value of [expanded] without
  /// calling [rebuild].
  ///
  /// By default, this method calls [onExpand] when [expanded] is `true` and
  /// [onCollapse] when [expanded] is `false`.
  void setExpansionState(T node, bool expanded) {
    expanded ? onExpand(node) : onCollapse(node);
  }

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so that
  /// listeners may handle the updated values.
  ///
  /// Example:
  /// ```dart
  /// class Node {
  ///   List<Node> children;
  /// }
  /// TreeController<Node> controller = ...;
  ///
  /// void addChild(Node parent, Node child) {
  ///   parent.children.add(child);
  ///   controller.rebuild();
  /// }
  ///```
  void rebuild() => notifyListeners();

  /// Updates the expansion state of [node] to the opposite state, then calls
  /// [rebuild].
  void toggleExpansion(T node) {
    getExpansionState(node) ? onCollapse(node) : onExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `true`, then calls [rebuild].
  ///
  /// If [node] is already expanded, nothing happens.
  void expand(T node) {
    if (getExpansionState(node)) return;
    onExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `false`, then calls [rebuild].
  ///
  /// If [node] is already collapsed, nothing happens.
  void collapse(T node) {
    if (!getExpansionState(node)) return;
    onCollapse(node);
    rebuild();
  }

  void _applyCascadingAction(Iterable<T> nodes, Visitor<T> action) {
    for (final T node in nodes) {
      action(node);
      _applyCascadingAction(childrenProvider(node), action);
    }
  }

  /// Traverses the subtrees of [nodes] in depth first order expanding every
  /// visited node, then calls [rebuild].
  void expandCascading(Iterable<T> nodes) {
    _applyCascadingAction(nodes, onExpand);
    rebuild();
  }

  /// Traverses the subtrees of [nodes] in depth first order collapsing every
  /// visited node, then calls [rebuild].
  void collapseCascading(Iterable<T> nodes) {
    _applyCascadingAction(nodes, onCollapse);
    rebuild();
  }

  /// Walks up the ancestors of [node] setting their expansion state to `true`.
  /// Note: [node] is not expanded by this method.
  ///
  /// This can be used to reveal a hidden node (e.g. when searching for a node
  /// in a search view).
  ///
  /// [parentProvider] should return the direct parent of the given node, this
  /// callback is used to traverse the ancestors of [node].
  void expandPath(T node, ParentProvider<T> parentProvider) {
    T? current = parentProvider(node);

    while (current != null) {
      onExpand(current);
      current = parentProvider(current);
    }

    rebuild();
  }

  @override
  void dispose() {
    _expandedNodes = null;
    super.dispose();
  }
}
