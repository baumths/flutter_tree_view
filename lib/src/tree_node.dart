import 'dart:collection';

import 'internal.dart';

// TODO: Missing Documentation
class TreeNode with LineMixin {
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
    if (_isExpanded == value) return;
    _isExpanded = value;

    // Notify the [TreeView] Widget if visible. (_expansionCallback != null)
    _expansionCallback?.call(this);
  }

  /// Sets `isExpanded` to `true`.
  void expand() => isExpanded = true;

  /// Sets `isExpanded` of this node and every node under it to `false`.
  void collapse() => visitSubtree((node) => node.isExpanded = false);

  /// Toggles `isExpanded` to the opposite state.
  void toggleExpanded() => isExpanded ? collapse() : expand();

  /* ~~~~~~~~~~ SELECTION RELATED ~~~~~~~~~~ */

  /// Whether or not this node is selected.
  bool get isSelected => _isSelected;
  var _isSelected = false;
  set isSelected(bool value) {
    if (value == _isSelected) return;
    _isSelected = value;

    // Update the view if not null.
    _updateCallback?.call();
  }

  /// Sets `isSelected` to `true`.
  void select() => toggleSelected(true);

  /// Sets `isSelected` to `false`.
  void deselect() => toggleSelected(false);

  /// Toggles `isSelected` to the opposite state.
  void toggleSelected([bool? value]) => isSelected = value ?? !_isSelected;

  /* ~~~~~~~~~~ ENABLE/DISABLE RELATED ~~~~~~~~~~ */

  /// Whether or not this node can be interacted with.
  bool get isEnabled => _isEnabled;
  var _isEnabled = true;
  set isEnabled(bool value) {
    if (value == _isEnabled) return;
    _isEnabled = value;

    // Update the view if not null.
    _updateCallback?.call();
  }

  /// Sets `isEnabled` to `true`.
  void enable() => toggleEnabled(true);

  /// Sets `isEnabled` to `false`.
  void disable() => toggleEnabled(false);

  /// Toggles `isEnabled` to opposite state.
  void toggleEnabled([bool? value]) => isEnabled = value ?? !_isEnabled;

  /* ~~~~~~~~~~ NODE RELATED ~~~~~~~~~~ */

  /// The distance between this node and the root node.
  int get depth => isRoot ? -1 : parent!.depth + 1;

  /// Whether this node is the last one in the subtree (empty children).
  bool get isLeaf => _children.isEmpty;

  /// Whether or not this node is the root.
  bool get isRoot => parent == null;

  /// Whether this node is a direct child of the root node.
  bool get isMostTopLevel => depth == 0;

  /// Whether or not this node is the last child of its parent.
  bool get hasNextSibling => isRoot ? false : this != parent!.children.last;

  /// Applies the function [fn] to every node in the subtree
  /// starting from this node in breadth first traversal.
  void visitSubtree(TreeViewCallback fn) {
    final queue = Queue<TreeNode>()..add(this);

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      fn(node);
      queue.addAll(node.children);
    }
  }

  /// Starting from this node, searches the subtree
  /// looking for a node key that match [key],
  /// returns `null` if no node was found with the given [key].
  TreeNode? find(Key key) => nullableSubtreeGenerator(this).firstWhere(
        (descendant) => descendant == null ? false : descendant.key == key,
        orElse: () => null,
      );

  /* ~~~~~~~~~~ OTHER ~~~~~~~~~~ */

  /// Callback for when either `isEnabled` or `isSelected` state changes.
  ///
  /// Usually used with [StatefulWidget]'s `setState`.
  ///
  /// Make sure to call `removeUpdateCallback` when the widget holding this node
  /// gets disposed, otherwise this node could be calling `setState` on other
  /// widgets and break your [TreeView].
  VoidCallback? get updateCallback => _updateCallback;
  VoidCallback? _updateCallback;

  /// Sets the callback [cb] that gets called when
  /// `isEnabled` or `isSelected` state changes.
  void addUpdateCallback(VoidCallback cb) => _updateCallback = cb;

  /// Sets `updateCallback` to null.
  void removeUpdateCallback() => _updateCallback = null;

  /// Casts [data] as [T].
  T dataAs<T>() => data as T;

  @override
  String toString() => 'TreeNode(data: $data)';

  /* ~~~~~~~~~~ PRIVATE ~~~~~~~~~~ */

  /// Callback used to notify [TreeView] when the expansion of this node changes.
  ///
  /// This property is null when the [Widget] it belongs to is not rendered.
  TreeViewCallback? _expansionCallback;
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

/// Extension to hide internal functionality.
extension TreeNodeX on TreeNode {
  /// Whether or not this node can be removed from the view.
  ///
  /// For the view to not be empty, nodes with depth of 0 must not be removed.
  bool get isRemovable => depth > 0;

  /// Sets the callback [cb] to notify [TreeView]
  /// when the expansion of this node changes.
  void addExpansionCallback(TreeViewCallback cb) => _expansionCallback = cb;

  /// Sets `_expansionCallback` to null meaning that
  /// this node is no longer in the view.
  void removeExpansionCallback() => _expansionCallback = null;
}
