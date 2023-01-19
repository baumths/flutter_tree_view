import 'package:flutter/foundation.dart'
    show DiagnosticPropertiesBuilder, Diagnosticable, DiagnosticsProperty;

import 'typedefs.dart' show ChildrenProvider, Mapper, Visitor;

/// The default level used for root nodes when flattening the tree.
const int defaultTreeRootLevel = 0;

/// A mixin interface used to build the flat representation of tree structures
/// formatted as a single flat list of [TreeEntry] objects which contains the
/// relevant tree node properties to build tree views.
mixin TreeFlattener<T extends Object> {
  /// The roots of the tree.
  ///
  /// These nodes are used as a starting point to build the flat representation
  /// of the tree.
  Iterable<T> get roots;

  /// A callback that must provide the children of a given node.
  ///
  /// This callback will be used to build the flat representation of the tree.
  ///
  /// Avoid doing heavy computations in this callback since it is going to be
  /// called a lot during tree flattening.
  ChildrenProvider<T> get childrenProvider;

  /// The current expansion state of [node].
  ///
  /// This method is used during flattening to collect the expansion state of
  /// tree nodes and store it in [TreeEntry.isExpanded].
  bool getExpansionState(T node);

  /// Traverses the subtrees of [nodes] in depth first order creating and
  /// accumulating [TreeEntry] instances for each visited node to then return
  /// it as a plain dart [List].
  ///
  /// If [nodes] is absent, [roots] will be used instead.
  ///
  /// [descendCondition] is used to determine if the descendants of the entry
  /// passed to it should be included in the final flat tree or not. Defaults
  /// to `(TreeEntry<T> entry) => entry.isExpanded` when not provided, wich
  /// makes sure only "visible" nodes get included in the flattened tree.
  ///
  /// [onTraverse] is an optional function that is called after a [TreeEntry]
  /// is created but before descending into its subtree.
  ///
  /// [rootLevel] the starting level to use for root nodes, usual values are
  /// `0` and `1`, defaults to [defaultTreeRootLevel].
  ///
  /// [unreachableLevelsWithVerticalLines] aditional levels that should paint
  /// vertical lines. Used by [SliverTree] when animating the expand/collapse
  /// state changes of nodes to add the levels that cannot be reached by the
  /// virtual subtree.
  List<TreeEntry<T>> buildFlatTree({
    Iterable<T>? nodes,
    Mapper<TreeEntry<T>, bool>? descendCondition,
    Visitor<TreeEntry<T>>? onTraverse,
    int rootLevel = 0,
    Iterable<int>? unreachableLevelsWithVerticalLines,
  }) {
    final Mapper<TreeEntry<T>, bool> shouldDescend =
        descendCondition ?? (TreeEntry<T> entry) => entry.isExpanded;

    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
    int index = 0;

    void mapNodesToEntries({
      required TreeEntry<T>? parent,
      required Iterable<T> nodes,
      required int level,
    }) {
      TreeEntry<T>? lastEntry;

      for (final T node in nodes) {
        final TreeEntry<T> entry = TreeEntry<T>(
          node: node,
          index: index++,
          isExpanded: getExpansionState(node),
          level: level,
          parent: parent,
          unreachableLines: unreachableLevelsWithVerticalLines,
        );

        lastEntry = entry;

        onTraverse?.call(entry);
        flatTree.add(entry);

        late final Iterable<T> children = childrenProvider(node);

        if (shouldDescend(entry) && children.isNotEmpty) {
          mapNodesToEntries(
            parent: entry,
            nodes: children,
            level: level + 1,
          );
        }
      }

      lastEntry?._hasNextSibling = false;
    }

    mapNodesToEntries(
      parent: null,
      nodes: nodes ?? roots,
      level: rootLevel,
    );

    return flatTree;
  }
}

/// A mixin intereface used to get indentation details about a particular node
/// on a tree.
///
/// This mixin is used by [IndentGuide] and its subclasses to gather the needed
/// information when indenting tree nodes (and painting lines, if enabled).
mixin TreeIndentDetails {
  /// The [TreeIndentDetails] attached to the parent node of this details.
  ///
  /// If `null`, this details is attached to a root node.
  TreeIndentDetails? get parent;

  /// The level of the node that owns this details on the tree. Example:
  ///
  /// 0  1  2  3
  /// A  ⋅  ⋅  ⋅
  /// ├─ B  ⋅  ⋅
  /// │  ├─ C  ⋅
  /// │  │  └─ D
  /// │  └─ E
  /// F  ⋅
  /// └─ G
  int get level;

  /// Whether the node that owns this details has another node after it at the
  /// same level.
  ///
  /// Used when painting lines to decide if a node should have a vertical line
  /// that connects it to its next sibling. If a node is the last child of its
  /// parent, a half vertical line "└─" is painted instead of a full one "├─".
  ///
  /// Example:
  ///
  /// Root
  /// ├─ Child <- `hasNextSibling = true`
  /// ├─ Child <- `hasNextSibling = true`
  /// └─ Child <- `hasNextSibling = false`
  bool get hasNextSibling;

  /// Whether this details should skip indenting and painting.
  ///
  /// Nodes at level 0 or less have no decoration nor indent by default.
  bool get skipIndentAndPaint => level <= 0;

  /// Aditional levels that should paint vertical lines.
  ///
  /// Used by [SliverTree] when animating the expand/collapse state changes of
  /// nodes to add the levels that cannot be reached by the virtual subtree.
  Iterable<int>? get _unreachableLines => null;

  /// Used to determine where to paint the vertical lines based on the path from
  /// the root node to the node that owns this details.
  ///
  /// Should contain the levels of all ancestors that have sibling(s) after it
  /// at the same level. Example:
  ///
  /// In the below diagram:
  /// - The "→" shows the level that must be added to the set.
  /// - The "{}" shows the levels of that row that have a vertical line.
  /// - The "__X" represents the space each "X" level occupies.
  ///
  /// __0__1__2__3__4__5
  ///   ⋅A ⋅  ⋅  ⋅  ⋅  ⋅  {}
  ///   →├─⋅B ⋅  ⋅  ⋅  ⋅  {1}
  ///   →│ →├─⋅C ⋅  ⋅  ⋅  {1,2}
  ///   →│ →│ ⋅└─⋅D ⋅  ⋅  {1,2}
  ///   →│ →│ ⋅  →├─⋅E ⋅  {1,2,4}
  ///   →│ →│ ⋅  →│ ⋅└─⋅F {1,2,4} *
  ///   →│ →│ ⋅  ⋅└─⋅G ⋅  {1,2}
  ///   →│ ⋅└─ H ⋅  ⋅  ⋅  {1}
  ///   →I ⋅  ⋅  ⋅  ⋅  ⋅  {}
  ///   ⋅└─⋅J ⋅  ⋅  ⋅  ⋅  {}
  ///
  /// How to read (*):
  /// The node "F" is sitting at level 5, has vertical lines at {1,2,4},
  /// a blank space at {3} and an "L" shaped line at {5}.
  ///
  /// Used by [ConnectingLinesGuide] to correctly paint lines and its
  /// connections at each level.
  Iterable<int> get levelsWithVerticalLines sync* {
    yield* _unreachableLines ?? const Iterable.empty();

    TreeIndentDetails? current = this;
    while (current != null && current.level > 0) {
      if (current.hasNextSibling) yield current.level;
      current = current.parent;
    }
  }
}

/// Used to store useful information about [node] in a flattened tree.
///
/// Instances of [TreeEntry]s are created internally while flattening a tree.
///
/// The [TreeEntry] instances are short lived, each time the flat tree is
/// rebuilt, a new [TreeEntry] is assigned to [node].
class TreeEntry<T extends Object> with TreeIndentDetails, Diagnosticable {
  /// Creates a [TreeEntry].
  TreeEntry({
    required this.node,
    required this.index,
    required this.isExpanded,
    required this.level,
    required this.parent,
    Iterable<int>? unreachableLines,
  }) : _unreachableLines = unreachableLines;

  /// The tree node that originated this entry.
  final T node;

  /// The index of [node] in the list returned by [buildFlatTree].
  final int index;

  /// The expansion state of [node].
  ///
  /// This value may change since this entry was created.
  final bool isExpanded;

  @override
  final int level;

  @override
  bool get hasNextSibling => _hasNextSibling;
  bool _hasNextSibling = true;

  /// The direct parent of [node] on the tree.
  @override
  final TreeEntry<T>? parent;

  @override
  final Iterable<int>? _unreachableLines;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('node', node))
      ..add(DiagnosticsProperty<int>('index', index))
      ..add(DiagnosticsProperty<bool>('isExpanded', isExpanded))
      ..add(DiagnosticsProperty<int>('level', level))
      ..add(DiagnosticsProperty<bool>('hasNextSibling', hasNextSibling))
      ..add(DiagnosticsProperty<T?>('parent node', parent?.node));
  }
}
