import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'tree_expansion_state.dart';
import 'typedefs.dart';

/// A controller that can be used to dynamically update the state of a tree.
///
/// Whenever this controller notifies its listeners any attached [SliverTree]s
/// will assume that the tree structure changed in some way and will rebuild
/// their internal flat representaton of the tree, showing/hiding the updated
/// nodes (if any).
class TreeController<T extends Object> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// [expansionState], the tree nodes expansion state cache, when absent,
  /// defaults to [TreeExpansionStateSet].
  TreeController({
    TreeExpansionState<T>? expansionState,
  }) : _expansionState = expansionState ?? TreeExpansionStateSet<T>();

  /// The tree nodes expansion state cache.
  ///
  /// When not provided, defaults to [TreeExpansionStateSet].
  TreeExpansionState<T> get expansionState => _expansionState;
  TreeExpansionState<T> _expansionState;
  set expansionState(TreeExpansionState<T> state) {
    if (_expansionState == state) return;
    _expansionState = state;
    rebuild();
  }

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so that
  /// listeners may handle the updated values.
  /// Most methods of this controller (like expand, collapse, etc.) already call
  /// [rebuild] inplicitly.
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

  void _doCollapse(T node) => expansionState.set(node, false);
  void _doExpand(T node) => expansionState.set(node, true);

  /// Updates the expansion state of [node] to the opposite state, then calls
  /// [rebuild].
  void toggleExpansion(T node) {
    expansionState.get(node) ? _doCollapse(node) : _doExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `true`, then calls [rebuild].
  ///
  /// If [node] is already expanded, nothing happens.
  void expand(T node) {
    if (expansionState.get(node)) return;
    _doExpand(node);
    rebuild();
  }

  /// Sets the expansion state of [node] to `false`, then calls [rebuild].
  ///
  /// If [node] is already collapsed, nothing happens.
  void collapse(T node) {
    if (!expansionState.get(node)) return;
    _doCollapse(node);
    rebuild();
  }

  void _applyCascadingAction(
    Iterable<T> nodes,
    ChildrenProvider<T> childrenProvider,
    Visitor<T> action,
  ) {
    for (final T node in nodes) {
      action(node);
      _applyCascadingAction(
        childrenProvider(node),
        childrenProvider,
        action,
      );
    }
  }

  /// Traverses the subtrees of [nodes] in depth first order expanding every
  /// visited node, then calls [rebuild].
  void expandCascading(
    Iterable<T> nodes,
    ChildrenProvider<T> childrenProvider,
  ) {
    _applyCascadingAction(nodes, childrenProvider, _doExpand);
    rebuild();
  }

  /// Traverses the subtrees of [nodes] in depth first order collapsing every
  /// visited node, then calls [rebuild].
  void collapseCascading(
    Iterable<T> nodes,
    ChildrenProvider<T> childrenProvider,
  ) {
    _applyCascadingAction(nodes, childrenProvider, _doCollapse);
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
      _doExpand(current);
      current = parentProvider(current);
    }

    rebuild();
  }
}
