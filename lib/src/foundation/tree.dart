import 'dart:math' as math show max;

import 'package:flutter/foundation.dart'
    show DiagnosticPropertiesBuilder, Diagnosticable, DiagnosticsProperty;

/// Signature of a function that takes a `T` value and returns a `R` value.
typedef Mapper<T, R> = R Function(T value);

/// Signature of a function used to visit nodes during tree traversal.
typedef Visitor<T> = void Function(T node);

/// An interface for handling the state of the nodes that compose the tree.
///
/// A [Tree] is used as a data provider to build the tree hierarchy on demand.
///
/// The methods of this class are going to be called very frequently during
/// flattening and command executions, consider caching the results.
abstract class Tree<T extends Object> {
  /// Enable subclasses to declare constant constructors.
  const Tree();

  /// The default level used for root nodes when flattening the tree.
  static const int defaultRootLevel = 0;

  /// The nodes that are used as the starting point to build the tree hierarchy
  /// on demand.
  ///
  /// This getter is going to be called very frequently when flattening the
  /// tree, consider caching the results.
  List<T> get roots;

  /// A helper method to get the unique identifier of [node].
  ///
  /// Override this method to provide an id for [node] if its `operator ==` and
  /// `hashCode` are expensinve. The recommended id types to use are [int],
  /// [String], [Key], etc, depending on the data structure used.
  ///
  /// A unique id is required to enable property caching for [node], e.g., to
  /// cache the animating state of nodes when expanding/collapsing.
  ///
  /// Make sure the id provided for a node is always the same and unique among
  /// other ids, otherwise it could lead to inconsistent tree state.
  ///
  /// Returns [node] by default.
  Object getId(T node) => node;

  /// Called, as needed when composing the tree, to get the children of [node].
  ///
  /// This method is going to be called very frequently when flattening the
  /// tree, consider caching the results.
  List<T> getChildren(T node);

  /// Should return the current expansion state of [node].
  ///
  /// Usual implementations look something like the following:
  ///
  /// ```dart
  /// class Node {
  ///   bool isExpanded = false;
  /// }
  ///
  /// // Assuming `Tree<Node>`
  ///
  /// bool getExpansionState(Node node) => node.isExpanded;
  ///
  /// // Or, assuming `Tree<String>`
  ///
  /// final Set<String> expandedNodes = <String>{};
  ///
  /// bool getExpansionState(String node) => expandedNodes.contains(node);
  /// ```
  bool getExpansionState(T node);

  /// Should update the expansion state of [node].
  /// The [expanded] parameter represents the node's **new** state.
  ///
  /// There's no need to call [State.setState] from this method, all tree
  /// operations should be done from a [TreeController] which will use this
  /// method to properly update the expansion state of tree nodes.
  ///
  /// Usual implementations look something like the following:
  ///
  /// ```dart
  /// class Node {
  ///   bool isExpanded = false;
  /// }
  ///
  /// // Assuming `Tree<Node>`
  ///
  /// void setExpansionState(Node node, bool expanded) {
  ///   node.isExpanded = expanded;
  /// }
  ///
  /// // Or, assuming `Tree<String>`
  ///
  /// final Set<String> expandedNodes = <String>{};
  ///
  /// void setExpansionState(String node, bool expanded) {
  ///   if (expanded) {
  ///     expandedNodes.add(node);
  ///   } else {
  ///     expandedNodes.remove(node);
  ///   }
  /// }
  /// ```
  void setExpansionState(T node, bool expanded);

  /// Convenient method for building a list composed by the flat representation
  /// of this tree.
  ///
  /// Traverses the tree creating [TreeEntry] instances for each visible node
  /// (i.e. parent is expanded) of the tree. This behavior can be overwitten
  /// providing the [descendCondition] callback.
  ///
  /// [descendCondition] defaults to `(TreeEntry<T> entry) => entry.isExpanded`.
  ///
  /// [startingLevel] the level to use for root nodes, negative values are
  /// ignored and [Tree.defaultRootLevel] is used instead.
  List<TreeEntry<T>> flatten({
    Mapper<TreeEntry<T>, bool>? descendCondition,
    Visitor<TreeEntry<T>>? onTraverse,
    int startingLevel = Tree.defaultRootLevel,
  }) {
    descendCondition ??= (TreeEntry<T> entry) => entry.isExpanded;
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];

    gatherTreeEntries(
      startingLevel: startingLevel,
      descendCondition: descendCondition,
      onTraverse: (TreeEntry<T> entry) {
        flatTree.add(entry);
        onTraverse?.call(entry);
      },
    );

    return flatTree;
  }

  /// Traverses this tree in depth first order creating [TreeEntry] instances
  /// for each node.
  ///
  /// To build a list of the flat representation of the tree:
  ///
  /// ```dart
  /// final Tree<T> tree = ...;
  /// final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
  ///
  /// gatherTreeEntries<T>(
  ///   onTraverse: flatTree.add,
  ///   descendCondition: (TreeEntry<T> entry) {
  ///     // Ensure only "visible" entries are traversed (i.e. skip the branch
  ///     // where `entry` is collapsed).
  ///     // To traverse the entire tree, return `true` from this callback.
  ///     return entry.isExpanded
  ///   },
  /// );
  /// ```
  ///
  /// Checkout [Tree.flatten] which covers the above boilerplate.
  ///
  /// [TreeEntry]s hold important information about its [TreeEntry.node], such
  /// as the id, index, level, expansion state, etc.
  ///
  /// [descendCondition] is used to determine if the descendants of the entry
  /// passed to it should be included in the final flat tree or not. To build
  /// a flat tree, use `(TreeEntry<T> entry) => entry.isExpanded` to make sure
  /// only "visible" nodes get included in the flattened tree.
  ///
  /// [onTraverse] is an optional function that is called after a [TreeEntry] is
  /// created but before descending to its children.
  ///
  /// [startingLevel] the level to use for root nodes, negative values are
  /// ignored and [Tree.defaultRootLevel] is used instead.
  void gatherTreeEntries({
    required Mapper<TreeEntry<T>, bool> descendCondition,
    Visitor<TreeEntry<T>>? onTraverse,
    int startingLevel = Tree.defaultRootLevel,
  }) {
    startingLevel = math.max(Tree.defaultRootLevel, startingLevel);
    int globalIndex = 0;

    TreeEntry<T>? previousEntry;

    void mapNodesToEntries({
      required TreeEntry<T>? parent,
      required List<T> nodes,
      required int level,
    }) {
      TreeEntry<T>? lastEntry;

      for (final T node in nodes) {
        final TreeEntry<T> entry = TreeEntry<T>(
          id: getId(node),
          node: node,
          index: globalIndex++,
          level: level,
          isExpanded: getExpansionState(node),
          parent: parent,
        );

        lastEntry = entry;

        previousEntry?._nextEntry = entry;
        entry._previousEntry = previousEntry;

        previousEntry = entry;

        onTraverse?.call(entry);

        if (descendCondition(entry)) {
          mapNodesToEntries(
            parent: entry,
            nodes: getChildren(node),
            level: level + 1,
          );
        }
      }

      lastEntry?._hasNextSibling = false;
    }

    mapNodesToEntries(
      parent: null,
      nodes: roots,
      level: startingLevel,
    );
  }

  /// Walks the tree in depth first order calling [visitor] on each node.
  ///
  /// [descendCondition] can be used to selectively walk or not a branch,
  /// defaults to returning `true`.
  ///
  /// [startingNodes] can be used to start from a deeper branch, defaults to
  /// [roots].
  void traverse({
    required Visitor<T> visitor,
    Iterable<T>? startingNodes,
    Mapper<T, bool>? descendCondition,
  }) {
    final Mapper<T, bool> shouldDescend = descendCondition ?? (T _) => true;

    void doTraverse(Iterable<T> nodes) {
      for (final T node in nodes) {
        visitor(node);

        if (shouldDescend(node)) {
          doTraverse(getChildren(node));
        }
      }
    }

    doTraverse(startingNodes ?? roots);
  }
}

/// The object that represents a node on a tree.
/// Used to store useful information about [node] in the current tree.
///
/// Instances of [TreeEntry]s are created internally while flattening the tree.
///
/// The [TreeEntry] instances are short lived, each time the flat tree is
/// rebuilt, a new [TreeEntry] is assigned to [node] with fresh data.
class TreeEntry<T extends Object> with Diagnosticable {
  /// Creates a [TreeEntry].
  TreeEntry({
    required this.id,
    required this.node,
    required this.index,
    required this.level,
    required this.isExpanded,
    bool hasNextSibling = true,
    this.parent,
  }) : _hasNextSibling = hasNextSibling;

  /// The unique id bound to [node] by [Tree.getId].
  final Object id;

  /// The node attached by [Tree.flatten] to this entry.
  final T node;

  /// The current index of this entry in the list returned by [Tree.flatten].
  final int index;

  /// The level of this entry on the tree.
  ///
  /// Example:
  /// ```dart
  /// /*
  ///   0
  ///   |- 1
  ///   |  '- 2
  ///   |     '- 3
  ///   0
  ///   '- 1
  /// */
  /// ```
  final int level;

  /// The expansion state of [node] gotten from [Tree.getExpansionState].
  ///
  /// If `true`, the children of [node] are currently visible on the tree.
  final bool isExpanded;

  /// Whether this entry has another entry after it at the same level.
  ///
  /// Used when painting lines to decide if a node should have a vertical line
  /// that connects it to its next sibling. If a node is the last child of its
  /// parent, a half vertical line "└─" is drawn instead of full one "├─".
  ///
  /// Example:
  ///
  /// Root
  /// ├─ Child <- `hasNextSibling = true`
  /// ├─ Child <- `hasNextSibling = true`
  /// └─ Child <- `hasNextSibling = false`
  bool get hasNextSibling => _hasNextSibling;
  bool _hasNextSibling;

  /// The direct parent of this entry on the tree.
  final TreeEntry<T>? parent;

  /// The entry before this in the flattened tree.
  ///
  /// The only entry that has `previousEntry == null` is the first root of the
  /// tree.
  TreeEntry<T>? get previousEntry => _previousEntry;
  TreeEntry<T>? _previousEntry;

  /// The entry after this in the flattened tree.
  ///
  /// If `null`, this entry is the last element of the flattened tree.
  TreeEntry<T>? get nextEntry => _nextEntry;
  TreeEntry<T>? _nextEntry;

  /// Used to determine where to draw the vertical lines based on the path from
  /// the root entry to this entry.
  ///
  /// Returns a set containing the levels of all ancestors in the path from the
  /// entry at level [Tree.defaultRootLevel] to this entry that have one or more
  /// siblings after it at the same level.
  Set<int> get ancestorLevelsWithVerticalLines {
    return _ancestorLevelsWithVerticalLines ??= _findAncestorLevelsWithLines();
  }

  Set<int>? _ancestorLevelsWithVerticalLines;

  Set<int> _findAncestorLevelsWithLines() {
    if (level == Tree.defaultRootLevel) return const <int>{};
    return <int>{
      ...?_unreachableExtraLevels,
      ...?parent?.ancestorLevelsWithVerticalLines,
      if (hasNextSibling) level,
    };
  }

  /// When animating the expansion state of a node, a subtree widget is shown
  /// containing all descendents of the expanded node, to do that, it creates a
  /// new [Tree] "branched" from the main one overriding the [Tree.roots] getter
  /// to return the node that was toggled (pseudo root). When doing so, all
  /// context up the tree is lost (i.e. the lines that connect to the pseudo
  /// root from its ancestors in the main tree).
  ///
  /// This set is used by the subtree widget to include the lines from the
  /// ancestors of the pseudo root.
  Set<int>? _unreachableExtraLevels;

  /// Add aditional levels that should draw vertical lines.
  ///
  /// Used when animating the expand/collapse state changes of nodes to add the
  /// levels that cannot be reached by the branched subtree.
  void addVerticalLinesAtLevels(Set<int> levels) {
    _unreachableExtraLevels = levels;
    _ancestorLevelsWithVerticalLines = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object>('id', id))
      ..add(DiagnosticsProperty<T>('node', node))
      ..add(DiagnosticsProperty<int>('index', index))
      ..add(DiagnosticsProperty<int>('level', level))
      ..add(DiagnosticsProperty<bool>('isExpanded', isExpanded))
      ..add(DiagnosticsProperty<bool>('hasNextSibling', hasNextSibling))
      ..add(DiagnosticsProperty<TreeEntry<T>?>('parent', parent));
  }
}
