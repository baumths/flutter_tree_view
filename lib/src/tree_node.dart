import 'dart:collection' show UnmodifiableSetView;

import 'package:flutter/foundation.dart' show protected;

import 'lines_painter.dart' show TreeLine;
import 'utils.dart';

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
class TreeNode extends Comparable<TreeNode> {
  /// Creates a [TreeNode].
  ///
  /// Use [id] to dynamically manage this node later.
  /// The [TreeViewState.find] method can be used to locate any node
  /// through its id.
  /// [TreeNode.find] can also be used, but its scope is reduced to its subtree.
  TreeNode({required this.id, this.label = '', this.data});

  /// An id to easily find this node in the Tree.
  final String id;

  /// The label (name, title, ...) of this node.
  ///
  /// This will be used in [NodeWidget] if [NodeWidget.content] is null.
  final String label;

  /// Any data you may want to store or pass around.
  final Object? data;

  // * ~~~~~~~~~~ CHILDREN RELATED ~~~~~~~~~~ *

  final Set<TreeNode> _children = {};

  /// The list of child nodes.
  UnmodifiableSetView<TreeNode> get children => UnmodifiableSetView(_children);

  /// Whether this node has children or not.
  bool get hasChildren => _children.isNotEmpty;

  /// Convenience operator to get the [index]th child.
  TreeNode operator [](int index) => _children.elementAt(index);

  /// Returns an [Iterable] of every [TreeNode] under this.
  Iterable<TreeNode> get descendants => subtreeGenerator(this);

  /// Returns the last child of this node or `null` if [children] is empty.
  TreeNode? get lastChild => _children.isEmpty ? null : _children.last;

  /// Adds a single child to this node and sets its [parent] property to `this`.
  void addChild(TreeNode child) {
    // A node can't be neither child of its children nor parent of itself.
    if (child == parent || child == this) return;

    // Avoid duplicating nodes in the tree.
    if (child.parent != null) {
      child.parent!.removeChild(child);
    }

    child.parent = this;
    _children.add(child);
  }

  /// Adds a list of children to this node.
  void addChildren(Iterable<TreeNode> nodes) => nodes.forEach(addChild);

  /// Removes a single child from this node and set its parent to `null`.
  void removeChild(TreeNode child) {
    final wasRemoved = _children.remove(child);

    if (wasRemoved) {
      child.parent = null;
    }
  }

  /// This method removes this node from the tree.
  ///
  /// Moves every child in [this.children] to [this.parent.children] and
  /// removes [this] from [this.parent.children].
  ///
  /// Example:
  /// ```
  /// /*
  /// rootNode
  ///   |-- childNode1
  ///   │     |-- grandChildNode1
  ///   │     '-- grandChildNode2
  ///   '-- childNode2
  ///
  /// childNode1.delete() is called, the tree becomes:
  ///
  /// rootNode
  ///   |-- childNode2
  ///   |-- grandChildNode1
  ///   '-- grandChildNode2
  /// */
  /// ```
  /// If [parent] is null, this method has no effects.
  void delete() {
    parent?.addChildren([..._children]);
    parent?.removeChild(this);
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
    return findPathFromRoot(this).toList()..removeLast();
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
  ///
  /// If this method throws, the tree was malformed.
  bool get hasNextSibling => isRoot ? false : this != parent!.lastChild;

  /// Starting from this node, searches the subtree
  /// looking for a node id that match [id],
  /// returns `null` if no node was found with the given [id].
  TreeNode? find(String id) => nullableSubtreeGenerator(this).firstWhere(
        (descendant) => descendant == null ? false : descendant.id == id,
        orElse: () => null,
      );

  // * ~~~~~~~~~~ OTHER ~~~~~~~~~~ *

  @override
  int compareTo(TreeNode other) => id.compareTo(other.id);

  @override
  String toString() => 'TreeNode(id: $id, label: $label, data: $data)';

  @override
  bool operator ==(covariant TreeNode other) {
    if (identical(this, other)) return true;

    return other.id == id && other.data == data && other.label == label;
  }

  @override
  int get hashCode => id.hashCode ^ data.hashCode ^ label.hashCode;
}

/// Extension to hide internal functionality.
extension TreeNodeX on TreeNode {
  /// Whether or not this node can be removed from the view.
  ///
  /// For the view to not be empty, nodes with depth of 0 must not be removed.
  bool get isRemovable => depth > 0;

  /// The line used to prefix this [TreeNode].
  TreeLine get prefixLine {
    return hasNextSibling ? TreeLine.intersection : TreeLine.connection;
  }

  /// Checks if parent has sibling after it and chooses the line accordingly.
  ///
  /// If parent has a sibling after it, there should be a line connecting it to
  /// its sibling, otherwise a blank line should be drawn.
  TreeLine lastParentLineEquivalent(TreeLine line) {
    return line == TreeLine.intersection ? TreeLine.straight : TreeLine.blank;
  }

  /// A list of [TreeLine]s that defines how connected lines will be drawn
  /// when [TreeViewTheme.lineStyle] is set to [LineStyle.connected].
  List<TreeLine> get connectedLines {
    if (isRoot || isMostTopLevel) return const [];

    if (depth == 1) return [prefixLine];

    final parentLines = parent!.connectedLines;

    return [
      // Copy parent lines, except the last one.
      ...parentLines.sublist(0, parentLines.length - 1),
      // Swap the last line of parent to connect or not to siblings.
      lastParentLineEquivalent(parentLines.last),
      prefixLine,
    ];
  }

  /// A list of [TreeLine] that defines how scoped lines will be drawn
  /// when [TreeViewTheme.lineStyle] is set to [LineStyle.scoped].
  List<TreeLine> get scopedLines {
    if (isRoot || isMostTopLevel) return const [];

    return List<TreeLine>.generate(
      depth,
      (_) => TreeLine.straight,
      growable: false,
    );
  }
}
