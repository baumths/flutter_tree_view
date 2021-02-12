import 'internal.dart';

/// This class represents one node in the Tree.
///
/// * ### Adding children:
///
///   Use either `addChild` or `addChildren` to modify the children of this node.
/// The [children] property is not present in the constructor to make it easy
/// to set the parent of this node automatically.
///
/// * ### Removing children:
///
///   Use either `removeChild` or `clearChildren` to remove any child from this
/// node, both methods set children's parent property to `null`.
///
/// * ### Updating the view:
///
///   For convenience use `addUpdateCallback` & `removeUpdateCallback` to set
/// a callback that's called whenever `isSelected` or `isEnabled` state changes.
///
///   If you're using [NodeWidget], it automatically adds and removes the
/// `updateCallback` for you.
///
/// * ### Expansion:
///
///   __If the node is currently visible__ calling either `expand`, `collapse`
/// or `toggleExpanded` will trigger a callback to update the [TreeView].
/// Useful to avoid using [TreeViewController] within the [TreeView] subtree.
class TreeNode {
  /// Creates a [TreeNode].
  ///
  /// Set [id] if you want to dynamically manage this node later.
  /// The [TreeViewController.find] method can be used to locate any node
  /// through its id.
  /// [TreeNode.find] can also be used, but its scope is reduced to its subtree.
  TreeNode({this.id, this.data});

  /// An id to easily find this node in the Tree.
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
    // A node can't be child of its children neither parent of itself.
    if (child == parent || child == this) return;
    // Avoid duplicating nodes.
    if (child.parent != null) child.parent!.removeChild(child);

    child.parent = this;
    _children.add(child);
  }

  /// Adds a list of children to this node.
  void addChildren(Iterable<TreeNode> nodes) => nodes.forEach(addChild);

  /// Removes a single child from this node and set its parent to `null`.
  void removeChild(TreeNode child) {
    final wasRemoved = _children.remove(child);
    if (wasRemoved) child.parent = null;
  }

  /// Removes all children from this node,
  /// sets the parent of every child of this node to null.
  ///
  /// Returns the old children to easily move nodes to another parent.
  List<TreeNode> clearChildren() {
    _children.forEach((node) => node.parent = null);
    final _backup = List<TreeNode>.from(_children, growable: false);

    _children.clear();
    return _backup;
  }

  // * ~~~~~~~~~~ PARENT RELATED ~~~~~~~~~~ *

  /// If `null`, this node is the root of the tree.
  ///
  /// This property is set by [TreeNode.addChild].
  TreeNode? get parent => _parent;
  TreeNode? _parent;
  @protected
  set parent(TreeNode? newParent) => _parent = newParent;

  /// Returns the path from the root node to this node, but excludes this.
  ///
  /// Example: [root, child, grandChild, ... `this.parent`]
  List<TreeNode> get ancestors {
    return findPathFromRoot(this)
        .where((n) => n != this)
        .toList(growable: false);
  }

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

  /// Calculates the amount of indentation of this node. `(depth * [indent])`
  ///
  /// [indent] => the amount of space added per level (example below).
  /// ```
  /// /* given: indent = 20.0
  /// __________________________________
  /// |___node___                      | depth = 0, indentation =  0
  /// |          |___node___           | depth = 1, indentation = 20
  /// |           <-indent->|___node___| depth = 2, indentation = 40
  /// | <-------- indentation -------> | */
  /// ```
  double calculateIndentation(double indent) => depth * indent;

  /// Applies the function [fn] to this and every node in the subtree
  /// that starts at this node in breadth first traversal.
  void visitSubtree(TreeViewCallback fn) {
    fn(this);
    subtreeGenerator(this).forEach(fn);
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

  // * ~~~~~~~~~~ LINES ~~~~~~~~~~ *

  /// A list of [TreeLine] that defines how connected lines will be drawn
  /// when [TreeViewTheme.lineStyle] is set to [LineStyle.connected].
  List<TreeLine> get connectedLines {
    if (isRoot) return const [];
    if (isMostTopLevel) {
      return [hasNextSibling ? TreeLine.intersection : TreeLine.connection];
    }
    final parentLines = parent!.connectedLines;
    return [
      ...parentLines.sublist(0, parentLines.length - 1),
      parentLines.last == TreeLine.intersection
          ? TreeLine.straight
          : TreeLine.blank,
      hasNextSibling ? TreeLine.intersection : TreeLine.connection,
    ];
  }

  /// A list of [TreeLine] that defines how scoped lines will be drawn
  /// when [TreeViewTheme.lineStyle] is set to [LineStyle.scoped].
  List<TreeLine> get scopedLines {
    return List<TreeLine>.generate(
      depth,
      (_) => TreeLine.straight,
      growable: false,
    );
  }
}
