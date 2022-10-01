import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../json_data.dart';

final treeProvider = Provider<DemoTree>((ref) => DemoTree());

final treeControllerProvider = Provider.autoDispose<TreeController<DemoNode>>(
  (ref) {
    final tree = ref.read(treeProvider);

    final controller = TreeController<DemoNode>(tree: tree);

    ref.onDispose(controller.dispose);
    return controller;
  },
);

final highlightedNodeProvider = StateProvider<DemoNode?>((ref) => null);

class DemoTree extends Tree<DemoNode> {
  DemoTree() : root = DemoNode.root {
    _getChildren(null).forEach(root.addChild);
  }

  final DemoNode root;

  Future<void> loadChildren(DemoNode parent) async {
    if (parent.children.isNotEmpty || parent.childrenLoaded) return;

    await Future<void>.delayed(const Duration(milliseconds: 500));

    _getChildren(parent.id).forEach(parent.addChild);

    parent._childrenLoaded = true;
  }

  Iterable<DemoNode> _getChildren(String? id) {
    return flatJsonData
        .where((data) => data['parentId'] == id)
        .map(DemoNode.fromJson);
  }

  @override
  List<DemoNode> get roots => root.children;

  @override
  String getId(DemoNode node) => node.id;

  @override
  List<DemoNode> getChildren(DemoNode node) => node.children;

  @override
  bool getExpansionState(DemoNode node) => node.isExpanded;

  @override
  void setExpansionState(DemoNode node, bool expanded) {
    node.isExpanded = expanded;
  }
}

class DemoNode {
  static int _autoIncrementedId = 0;
  static final root = DemoNode(id: '/', label: '/');

  DemoNode({
    String? id,
    required this.label,
    this.isExpanded = false,
    List<DemoNode>? children,
  })  : id = id ?? '${_autoIncrementedId++}',
        _children = children ?? <DemoNode>[] {
    for (final child in _children) {
      child._parent = this;
    }

    _childrenLoaded = _children.isNotEmpty;
  }

  factory DemoNode.fromJson(Map<String, Object?> json) {
    return DemoNode(
      id: json['id'] as String?,
      label: json['label'] as String? ?? 'no label',
    );
  }

  final String id;
  final String label;

  bool get childrenLoaded => _childrenLoaded;
  bool _childrenLoaded = false;

  bool get isLeaf => children.isEmpty && childrenLoaded;

  List<DemoNode> get children => _children;
  final List<DemoNode> _children;

  DemoNode? get parent => _parent;
  DemoNode? _parent;

  bool isExpanded;

  int get index => _parent?.children.indexOf(this) ?? 0;

  void addChild(DemoNode node) {
    _reparent(node);
    _children.add(node);
  }

  void insertChild(int index, DemoNode child) {
    if (child.parent == this) {
      _move(child, index);
    } else {
      _reparent(child);
      _children.insert(index, child);
    }
  }

  void removeChild(DemoNode child) {
    if (children.remove(child)) {
      child._parent = null;
    }
  }

  void _move(DemoNode child, int newIndex) {
    final int oldIndex = children.indexOf(child);

    if (newIndex > oldIndex) {
      --newIndex;
    }

    if (newIndex == oldIndex) return;

    children
      ..removeAt(oldIndex)
      ..insert(newIndex, child);
  }

  void _reparent(DemoNode child) {
    child._parent?.removeChild(child);
    child._parent = this;
  }

  @override
  String toString() => 'DemoNode(id: $id, label: $label)';
}
