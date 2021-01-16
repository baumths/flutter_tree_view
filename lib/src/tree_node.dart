import 'dart:collection';

import 'internal.dart';

// TODO: Missing Documentation
class TreeNode with LineMixin, ChangeNotifier {
  /// Constructor for [TreeNode].
  TreeNode({Key? key, this.data}) : key = key ?? UniqueKey();

  /// A key to find this node in the tree.
  final Key key;

  /// Any data you may want to store or pass around.
  final dynamic data;

  /* ~~~~~~~~~~ CHILDREN RELATED ~~~~~~~~~~ */

  /// The list of child nodes.
  List<TreeNode> get children => _children;
  final List<TreeNode> _children = [];

  /// Whether this node has children or not.
  bool get hasChildren => _children.isNotEmpty;

  /// Convenience operator to get the [index]th child.
  TreeNode operator [](int index) => _children[index];

  /// Adds a single child to this node.
  void addChild(TreeNode child) {
    // Avoid duplicating nodes.
    if (child.parent != null) child.parent!.removeChild(child);

    child._parent = this;
    _children.add(child);
  }

  /// Adds a list of children to this node.
  void addChildren(Iterable<TreeNode> nodes) => nodes.forEach(addChild);

  /// Removes a single child from this node and set its parent to `null`.
  void removeChild(TreeNode child) {
    final wasRemoved = _children.remove(child);
    if (wasRemoved) child._parent = null;
  }

  /* ~~~~~~~~~~ PARENT RELATED ~~~~~~~~~~ */

  /// If `null`, this node is the root of the tree.
  ///
  /// This property should only be set by [TreeNode.addChild].
  TreeNode? get parent => _parent;
  TreeNode? _parent;

  /* ~~~~~~~~~~ EXPANSION RELATED ~~~~~~~~~~ */

  /// Whether or not this node is expanded.
  bool get isExpanded => isRoot ? true : _isExpanded;
  var _isExpanded = false;
  set isExpanded(bool value) {
    if (value == _isExpanded) return;
    _isExpanded = value;
    notifyListeners();
  }

  /* ~~~~~~~~~~ SELECTION RELATED ~~~~~~~~~~ */

  /// Whether or not this node is expanded.
  bool get isSelected => _isSelected;
  var _isSelected = false;
  set isSelected(bool value) {
    if (value == _isSelected) return;
    _isSelected = value;
    notifyListeners();
  }

  /* ~~~~~~~~~~ ENABLE/DISABLE RELATED ~~~~~~~~~~ */

  /// Whether or not this node can be interacted with.
  bool get isEnabled => _isEnabled;
  var _isEnabled = false;
  set isEnabled(bool value) {
    if (value == _isEnabled) return;
    _isEnabled = value;
    notifyListeners();
  }

  /* ~~~~~~~~~~ NODE RELATED ~~~~~~~~~~ */

  /// Whether this node is the last one in the subtree (empty children).
  bool get isLeaf => _children.isEmpty;

  /// Whether or not this node is the root.
  bool get isRoot => parent == null;

  /// Starting from this node, searches the subtree
  /// looking for a node key that match [key],
  /// returns `null` if no node was found with the given [key].
  TreeNode? find(Key key) => nullableSubtreeGenerator(this).firstWhere(
        (descendant) => descendant == null ? false : descendant.key == key,
        orElse: () => null,
      );

  /* ~~~~~~~~~~ OTHER ~~~~~~~~~~ */

  /// Casts [data] as [T].
  T dataAs<T>() => data as T;

  @override
  String toString() => 'TreeNode(data: $data)';
}

/// Caches the lines for a [TreeNode].
mixin LineMixin {
  /// Cache to avoid rebuilding the list of lines.
  List<TreeLine>? _linesCache;

  /// List of [TreeLine] to be used as template
  /// to draw the lines for this node in the [TreeView].
  List<TreeLine> get lines => _linesCache ?? [];

  set lines(List<TreeLine> lines) => _linesCache = lines;
}

/// Adds internal methods to [TreeNode].
extension TreeNodeX on TreeNode {
  /// Whether or not this node can be removed from the view.
  bool get isRemovable => depth > 1;

  /// The distance between this node and the root node.
  int get depth => parent == null ? 0 : parent!.depth + 1;

  /// As root doesn't get displayed, the most top level node is 1 instead of 0.
  bool get isMostTopLevel => depth == 1;

  /// Whether or not this node is the last child of its parent.
  bool get hasNextSibling => isRoot ? false : this != parent!.children.last;

  /// Returns `false` if the lines of this node were already generated.
  bool get shouldBuildLines => _linesCache == null;

  /// Set this node as expanded.
  void expand() => isExpanded = true;

  /// Collapses the subtree starting at this node.
  void collapse() => visitSubtree((node) => node.isExpanded = false);

  /// Set this node as selected.
  void select() => isSelected = true;

  /// Unselects this node.
  void deselect() => isSelected = false;

  /// Set this node as enabled.
  void enable() => isEnabled = true;

  /// Disables this node.
  void disable() => isEnabled = false;

  /// Applies the function [fn] to every node in the subtree
  /// starting from this node in breadth first, pre-order traversal.
  void visitSubtree(void Function(TreeNode node) fn) {
    final queue = Queue<TreeNode>()..add(this);

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      fn(node);
      queue.addAll(node.children);
    }
  }
}
