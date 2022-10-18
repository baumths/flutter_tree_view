import 'package:flutter/foundation.dart'
    show
        DiagnosticPropertiesBuilder,
        Diagnosticable,
        DiagnosticableTreeMixin,
        DiagnosticsNode,
        DiagnosticsProperty,
        optionalTypeArgs;

/// Signature of a function that takes a `T` value and returns a `R` value.
typedef Mapper<T, R> = R Function(T value);

/// Signature of a function used to visit nodes during tree traversal.
typedef Visitor<T> = void Function(T node);

/// The default level used for root [TreeNode]s when flattening the tree.
const int defaultTreeRootLevel = 0;

/// A simple mixin on [TreeNode] that creates an ordinary [Object] as its id.
///
/// This mixin is useful in usecases where identifying tree nodes is not
/// important for the application; but the package still needs a way to reliably
/// cache some values for each tree node and a simple unique object is enough.
/// > From [Object]'s documentation:
/// > [Object] instances have no meaningful state, and are only useful
/// > through their identity. An [Object] instance is equal to itself
/// > only.
@optionalTypeArgs
mixin ImplicitTreeNodeId<T extends TreeNode<T>> on TreeNode<T> {
  @override
  final Object id = Object();
}

/// An interface for handling the nodes that compose a tree.
///
/// The properties of this class are going to be called very frequently during
/// flattening and command executions, consider caching the results (i.e. avoid
/// doing heavy computational tasks in [id], [children], [isExpanded],
/// [includeChildrenWhenFlattening], etc...).
abstract class TreeNode<T extends TreeNode<T>> with DiagnosticableTreeMixin {
  /// Abstract constant constructor.
  TreeNode({this.isExpanded = false});

  /// The unique identifier of this node.
  ///
  /// A unique id is required to enable property caching, e.g., to cache the
  /// animating state of nodes when expanding/collapsing.
  ///
  /// Make sure the id provided for a node is always the same and unique among
  /// other ids, otherwise it could lead to inconsistent tree state.
  ///
  /// See also:
  /// * [ImplicitTreeNodeId], which (in simple usecases) can be mixed in with
  ///   this node to provide a unique object as the id of each new instance.
  Object get id;

  /// The direct children of this node.
  Iterable<T> get children;

  /// The expansion state of this node.
  ///
  /// If `true`, this node is expanded and its subtree should be visible on a
  /// tree view.
  bool isExpanded;

  /// Convenient getter to access `children.isNotEmpty`.
  bool get hasChildren => children.isNotEmpty;

  /// Used when flattening the tree to decide if the children of this node
  /// should be traversed or not.
  ///
  /// Subclasses can override this method to change the default behavior.
  ///
  /// Defaults to `isExpanded && hasChildren`.
  bool get includeChildrenWhenFlattening => isExpanded && hasChildren;

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    if (children.isEmpty) {
      return <DiagnosticsNode>[DiagnosticsNode.message('children is empty')];
    }
    return children.map((T child) => child.toDiagnosticsNode()).toList();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Object>('id', id))
      ..add(DiagnosticsProperty<bool>('isExpanded', isExpanded));
  }
}

/// Convenient method for building a list composed by the flat representation
/// of the tree provided by the subtrees of [roots].
///
/// Traverses each root subtree creating [TreeEntry] instances for each visible
/// node as of [descendCondition], which, if not provided, defaults to
/// `(TreeEntry<T> entry) => entry.node.includeChildrenWhenFlattening`.
///
/// [startingLevel] the level to use for root nodes, must be a positive integer
/// and defaults to [defaultTreeRootLevel].
List<TreeEntry<T>> buildFlatTree<T extends TreeNode<T>>({
  required Iterable<T> roots,
  int startingLevel = defaultTreeRootLevel,
  Mapper<TreeEntry<T>, bool>? descendCondition,
  Visitor<TreeEntry<T>>? onTraverse,
}) {
  descendCondition ??= (TreeEntry<T> entry) {
    return entry.node.includeChildrenWhenFlattening;
  };

  final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];

  flatten<T>(
    roots: roots,
    descendCondition: descendCondition,
    startingLevel: startingLevel,
    onTraverse: (TreeEntry<T> entry) {
      flatTree.add(entry);
      onTraverse?.call(entry);
    },
  );

  return flatTree;
}

/// Traverses the subtree of each root node in depth first order creating
/// [TreeEntry] instances for each descendant node.
///
/// To build a list of the flat representation of a tree:
///
/// ```dart
/// final List<T> rootNodes = ...;
/// final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
///
/// gatherTreeEntries<T>(
///   roots: rootNodes,
///   onTraverse: flatTree.add,
/// );
/// ```
///
/// Checkout [buildFlatTree] which covers the above boilerplate.
///
/// [TreeEntry]s hold important information about its wrapped node, such as the
/// index, level, parent, etc.
///
/// [descendCondition] is used to determine if the descendants of the entry
/// passed to it should be included in the final flat tree or not. To build
/// a flat tree, use `(TreeEntry<T> entry) => entry.node.includeChildrenWhenFlattening`
/// to make sure only "visible" nodes get included in the flattened tree.
///
/// [onTraverse] is an optional function that is called after a
/// [TreeEntry] is created but before descending to its children.
///
/// [startingLevel] the level to use for root nodes, must be a positive integer
/// and defaults to [defaultTreeRootLevel].
void flatten<T extends TreeNode<T>>({
  required Iterable<T> roots,
  required Mapper<TreeEntry<T>, bool> descendCondition,
  int startingLevel = defaultTreeRootLevel,
  Visitor<TreeEntry<T>>? onTraverse,
}) {
  assert(startingLevel >= 0);
  int globalIndex = 0;

  TreeEntry<T>? previousEntry;

  void mapNodesToEntries({
    required TreeEntry<T>? parent,
    required Iterable<T> nodes,
    required int level,
  }) {
    TreeEntry<T>? lastEntry;

    for (final T node in nodes) {
      final TreeEntry<T> entry = TreeEntry<T>(
        node: node,
        index: globalIndex++,
        level: level,
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
          nodes: node.children,
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

  /// The level of the node that owns this details on the tree.
  ///
  /// Example:
  /// ```dart
  /// /*
  /// 0  1  2  3  4
  ///    A
  ///    ├─ B
  ///    │  ├─ C
  ///    │  │  └─ D
  ///    │  └─ E
  ///    F
  ///    └─ G
  /// */
  /// ```
  int get level;

  /// Whether the node that owns this details has another node after it at the
  /// same level.
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
  bool get hasNextSibling;

  /// Whether this details should skip indenting and painting.
  ///
  /// Nodes at level 0 or less have no decoration nor indent by default.
  bool get skipIndentAndPaint => level <= 0;

  /// Used to determine where to draw the vertical lines based on the path from
  /// the root node to the node that owns this details.
  ///
  /// Should contain the levels of all ancestors that have sibling(s) after it
  /// at the same level. Example:
  ///
  /// ```dart
  /// /*
  /// The "→" arrow shows the level that must be added to the set.
  /// The "{}" shows the levels of that row that have a vertical line.
  ///
  /// 0  1  2  3  4  5  6 ...
  ///    A  ⋅  ⋅  ⋅  ⋅  ⋅  {}
  ///   →├─ B  ⋅  ⋅  ⋅  ⋅  {1}
  ///   →│ →├─ C  ⋅  ⋅  ⋅  {1,2}
  ///   →│ →│  └─ D  ⋅  ⋅  {1,2}
  ///   →│ →│    →├─ E  ⋅  {1,2,4}
  /// * →│ →│    →│  └─ F  {1,2,4}
  ///   →│ →│     └─ G  ⋅  {1,2}
  ///   →│  └─ H  ⋅  ⋅  ⋅  {1}
  ///   →I  ⋅  ⋅  ⋅  ⋅  ⋅  {}
  ///    └─ J  ⋅  ⋅  ⋅  ⋅  {}
  ///
  /// How to read (*):
  /// The node "F" has vertical lines at levels {1,2,4}, a blank space at level
  /// {3} and an "L" shaped line at level {5}.
  /// */
  /// ```
  ///
  /// The [ConnectingLinesGuide] will use this set to correctly paint lines and
  /// its connections at each level.
  Set<int> get ancestorLevelsWithVerticalLines {
    return _ancestorLevelsWithVerticalLines ??= _findAncestorLevelsWithLines();
  }

  Set<int>? _ancestorLevelsWithVerticalLines;

  Set<int> _findAncestorLevelsWithLines() {
    if (level == defaultTreeRootLevel) return const <int>{};
    return <int>{
      ...?_unreachableExtraLevels,
      ...?parent?.ancestorLevelsWithVerticalLines,
      if (hasNextSibling) level,
    };
  }

  /// When animating the expansion state of a node, a subtree widget is shown
  /// containing all descendents of the expanded node, to do that, a new flat
  /// tree is built using the animating node as its "virtual root". When doing
  /// so, all context up the tree is lost (i.e. the lines that connect to the
  /// virtual root from its ancestors in the main tree).
  Set<int>? _unreachableExtraLevels;

  /// Add aditional levels that should draw vertical lines.
  ///
  /// Used when animating the expand/collapse state changes of nodes to add the
  /// levels that cannot be reached by the virtual subtree.
  void addVerticalLinesAtLevels(Set<int> levels) {
    _unreachableExtraLevels = levels;
    _ancestorLevelsWithVerticalLines = null;
  }
}

/// Used to store useful information about [node] in a flattened tree.
///
/// Instances of [TreeEntry]s are created internally while flattening a tree.
///
/// The [TreeEntry] instances are short lived, each time the flat tree is
/// rebuilt, a new [TreeEntry] is assigned to [node] with fresh data.
class TreeEntry<T extends TreeNode<T>> with TreeIndentDetails, Diagnosticable {
  /// Creates a [TreeEntry].
  TreeEntry({
    required this.node,
    required this.index,
    required this.level,
    required this.parent,
    bool hasNextSibling = true,
  }) : _hasNextSibling = hasNextSibling;

  /// The [TreeNode] that originated this entry.
  final T node;

  /// The current index of [node] in the list returned by [TreeNode.flatten].
  final int index;

  @override
  final int level;

  @override
  bool get hasNextSibling => _hasNextSibling;
  bool _hasNextSibling;

  /// The direct parent of [node] on the tree.
  @override
  final TreeEntry<T>? parent;

  /// The entry before this in the flattened tree.
  ///
  /// The only entry that has `previousEntry == null` is the first entry of the
  /// flatteneed tree.
  TreeEntry<T>? get previousEntry => _previousEntry;
  TreeEntry<T>? _previousEntry;

  /// The entry after this in the flattened tree.
  ///
  /// If `null`, this entry is the last element of the flattened tree.
  TreeEntry<T>? get nextEntry => _nextEntry;
  TreeEntry<T>? _nextEntry;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<T>('node', node))
      ..add(DiagnosticsProperty<int>('index', index))
      ..add(DiagnosticsProperty<int>('level', level))
      ..add(DiagnosticsProperty<bool>('hasNextSibling', hasNextSibling))
      ..add(DiagnosticsProperty<T?>('parent node', parent?.node));
  }
}
