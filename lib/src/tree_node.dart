import 'dart:collection';

import 'internal.dart';

// TODO: Missing Documentation
class TreeNode with LineMixin {
  /// Creates a [TreeNode].
  TreeNode({this.id, this.data});

  /// An id to find this node in the Tree.
  final int? id;

  /// Any data you may want to store or pass around.
  final dynamic data;

  // * ~~~~~~~~~~ CHILDREN RELATED ~~~~~~~~~~ *

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

  // * ~~~~~~~~~~ PARENT RELATED ~~~~~~~~~~ *

  /// If `null`, this node is the root of the tree.
  ///
  /// This property is set by [TreeNode.addChild].
  TreeNode? get parent => _parent;
  TreeNode? _parent;

  // * ~~~~~~~~~~ EXPANSION RELATED ~~~~~~~~~~ *

  /// Whether or not this node is expanded.
  bool get isExpanded => isRoot ? true : _isExpanded;
  bool _isExpanded = false;

  /// Sets `isExpanded` to `true`.
  void expand() {
    pExpand();
    _expansionCallback?.call(this);
  }

  /// Sets `isExpanded` of this node and every node under it to `false`.
  void collapse() {
    pCollapse();
    _expansionCallback?.call(this);
  }

  /// Toggles `isExpanded` to the opposite state.
  void toggleExpanded() => isExpanded ? collapse() : expand();

  // * ~~~~~~~~~~ SELECTION RELATED ~~~~~~~~~~ *

  /// Whether or not this node is selected.
  bool get isSelected => _isSelected;
  bool _isSelected = false;

  /// Sets `isSelected` to `true`.
  void select() => toggleSelected(true);

  /// Sets `isSelected` to `false`.
  void deselect() => toggleSelected(false);

  /// Toggles `isSelected` to the opposite state.
  void toggleSelected([bool? value]) {
    _isSelected = value ?? !_isSelected;
    _updateCallback?.call(); // Update the view if not null.
  }

  // * ~~~~~~~~~~ ENABLE/DISABLE RELATED ~~~~~~~~~~ *

  /// Whether or not this node can be interacted with.
  bool get isEnabled => _isEnabled;
  bool _isEnabled = true;

  /// Sets `isEnabled` to `true`.
  void enable() => toggleEnabled(true);

  /// Sets `isEnabled` to `false`.
  void disable() => toggleEnabled(false);

  /// Toggles `isEnabled` to opposite state.
  void toggleEnabled([bool? value]) {
    _isEnabled = value ?? !_isEnabled;
    _updateCallback?.call(); // Update the view if not null.
  }

  // * ~~~~~~~~~~ NODE RELATED ~~~~~~~~~~ *

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
  /// looking for a node id that match [id],
  /// returns `null` if no node was found with the given [id].
  TreeNode? find(int id) => nullableSubtreeGenerator(this).firstWhere(
        (descendant) => descendant == null ? false : descendant.id == id,
        orElse: () => null,
      );

  // * ~~~~~~~~~~ OTHER ~~~~~~~~~~ *

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

  @override
  String toString() => 'TreeNode(id: $id, data: $data)';

  // * ~~~~~~~~~~ PRIVATE ~~~~~~~~~~ *

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

  /// Package private expand.
  ///
  /// Used to avoid repetitively changing `isExpanded`
  /// when [TreeViewController.`expandNode`] is called.
  void pExpand() => _isExpanded = true;

  /// Package private collapse.
  ///
  /// Used to avoid repetitively changing `isExpanded`
  /// when [TreeViewController.`collapseNode`] is called.
  void pCollapse() => visitSubtree((node) => node._isExpanded = false);

  /// Sets the callback [cb] to notify [TreeView]
  /// when the expansion of this node changes.
  void addExpansionCallback(TreeViewCallback cb) => _expansionCallback = cb;

  /// Sets `_expansionCallback` to null meaning that
  /// this node is no longer in the view.
  void removeExpansionCallback() => _expansionCallback = null;
}
