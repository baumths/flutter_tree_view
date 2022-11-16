import 'package:flutter/foundation.dart' show ChangeNotifier;

import 'tree_node.dart';

/// A simple controller used by [SliverTree] to create and update the flat
/// representation of the tree built from [TreeController.roots].
class TreeController<T extends TreeNode<T>> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// The [roots] parameter is used by [SliverTree] as a starting point to
  /// build the flat representation of the roots hierarchies.
  TreeController({
    required Iterable<T> roots,
    required this.onExpansionChanged,
  }) : _roots = roots;

  /// The root [TreeNode]s of the tree.
  ///
  /// These nodes are used as a starting point to build the flat representation
  /// of the tree.
  ///
  /// When updating this property, [rebuild] is implicitly called.
  Iterable<T> get roots => _roots;
  Iterable<T> _roots;
  set roots(Iterable<T> nodes) {
    if (nodes == _roots) return;
    _roots = nodes;
    rebuild();
  }

  /// A callback that should update the expansion state of a tree node when
  /// called.
  ///
  /// The `bool expanded` parameter represents the **new** expansion state.
  final TreeExpansionStateSetter<T> onExpansionChanged;

  /// Notify listeners that the tree structure changed in some way.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so that
  /// listeners can rebuild their flat trees to include the new changes.
  ///
  /// Example:
  /// ```dart
  /// class Node extends TreeNode<Node> {
  ///   @override
  ///   bool isExpanded = false;
  /// }
  /// TreeController<Node> controller = ...;
  ///
  /// void expand(Node node) {
  ///   node.isExpanded = true;
  ///   controller.rebuild();
  /// }
  ///```
  void rebuild() => notifyListeners();

  /// Updates the expansion state of [node] to the opposite state and notifies
  /// listeners.
  void toggleExpansion(T node) {
    onExpansionChanged(node, !node.isExpanded);
    rebuild();
  }
}
