import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

final treeControllerProvider = Provider<DemoTreeController>((ref) {
  return DemoTreeController();
});

class DemoTreeController extends TreeController<DemoNode> {
  Iterable<DemoNode> get roots => DemoNode.virtualRoot.children;

  @override
  bool getExpansionState(DemoNode node) => node.isExpanded;

  @override
  void setExpansionState(DemoNode node, bool expanded) {
    node.isExpanded = expanded;
  }

  @override
  void expandAll([Iterable<DemoNode>? roots]) {
    super.expandAll(roots ?? this.roots);
  }

  @override
  void collapseAll([Iterable<DemoNode>? roots]) {
    super.collapseAll(roots ?? this.roots);
  }
}

const int _orphanNodeIndex = -1;

int _uniqueKey = 0;

class DemoNode extends TreeItem<DemoNode> {
  static final DemoNode virtualRoot = DemoNode(
    label: '/',
    children: _createSampleTree(),
  );

  DemoNode({
    required this.label,
    this.isExpanded = false,
    List<DemoNode>? children,
  })  : key = _uniqueKey++,
        _children = children ?? <DemoNode>[] {
    for (int index = 0; index < _children.length; index++) {
      _children[index]
        .._parent = this
        .._index = index;
    }
  }

  final String label;

  bool isExpanded;

  @override
  final int key;

  @override
  List<DemoNode> get children => _children;
  final List<DemoNode> _children;

  @override
  DemoNode get parent => _parent ?? virtualRoot;
  DemoNode? _parent;

  int get index => _index;
  int _index = _orphanNodeIndex;

  void addChild(DemoNode child) {
    _reparent(child);
    child._index = _children.length;
    _children.add(child);
  }

  void addChildren(Iterable<DemoNode> nodes) {
    int index = _children.length;

    for (final DemoNode node in nodes) {
      _reparent(node);
      node._index = index++;
      _children.add(node);
    }
  }

  void insertChild(int index, DemoNode child) {
    if (child.parent == this) {
      _move(child, index);
    } else {
      _reparent(child);
      _children.insert(index, child);
    }

    _reindexChildren();
  }

  void removeChild(DemoNode child) {
    _children.removeAt(child._index);
    child
      .._parent = null
      .._index = _orphanNodeIndex;
    _reindexChildren();
  }

  Iterable<DemoNode> clearChildren() {
    final List<DemoNode> nodes = <DemoNode>[];

    for (final DemoNode node in _children) {
      node
        .._parent = null
        .._index = _orphanNodeIndex;
      nodes.add(node);
    }

    _children.clear();
    return nodes;
  }

  void delete({bool recursive = true}) {
    if (recursive) {
      _deleteRecursive();
    } else {
      parent.addChildren(clearChildren());
    }

    parent.removeChild(this);
  }

  void _deleteRecursive() {
    for (final DemoNode node in clearChildren()) {
      node._deleteRecursive();
    }
  }

  void _move(DemoNode child, int newIndex) {
    if (newIndex > child._index) {
      --newIndex;
    }

    if (newIndex == child._index) return;

    _children
      ..removeAt(child._index)
      ..insert(newIndex, child);
  }

  void _reparent(DemoNode child) {
    child._parent?.removeChild(child);
    child._parent = this;
  }

  void _reindexChildren() {
    for (int index = 0; index < _children.length; index++) {
      _children[index]._index = index;
    }
  }
}

List<DemoNode> _createSampleTree() {
  return <DemoNode>[
    DemoNode(
      label: 'A',
      children: [
        DemoNode(label: 'A 1'),
        DemoNode(
          label: 'A 2',
          children: [
            DemoNode(label: 'A 2 1'),
          ],
        ),
      ],
    ),
    DemoNode(
      label: 'B',
      children: [
        DemoNode(
          label: 'B 1',
          children: [
            DemoNode(
              label: 'B 1 1',
              children: [
                DemoNode(label: 'B 1 1 1'),
                DemoNode(label: 'B 1 1 2'),
              ],
            ),
          ],
        ),
        DemoNode(
          label: 'B 2',
          children: [
            DemoNode(
              label: 'B 2 1',
              children: [
                DemoNode(label: 'B 2 1 1'),
              ],
            ),
          ],
        ),
        DemoNode(label: 'B 3'),
      ],
    ),
    DemoNode(
      label: 'C',
      children: [
        DemoNode(
          label: 'C 1',
          children: [
            DemoNode(label: 'C 1 1'),
          ],
        ),
        DemoNode(label: 'C 2'),
        DemoNode(label: 'C 3'),
        DemoNode(label: 'C 4'),
      ],
    ),
    DemoNode(
      label: 'D',
      children: [
        DemoNode(
          label: 'D 1',
          children: [
            DemoNode(label: 'D 1 1'),
          ],
        ),
      ],
    ),
    DemoNode(
      label: 'E',
      children: [
        DemoNode(label: 'E 1'),
      ],
    ),
    DemoNode(
      label: 'F',
      children: [
        DemoNode(label: 'F 1'),
        DemoNode(label: 'F 2'),
      ],
    ),
  ];
}
