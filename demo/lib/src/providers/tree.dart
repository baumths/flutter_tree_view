import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/foundation.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

export 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

final treeControllerProvider = Provider.autoDispose<TreeController<DemoNode>>(
  (ref) {
    final controller = TreeController<DemoNode>(
      root: DemoNode.root,
    );

    ref.listen(showRootProvider, ((_, next) => controller.showRoot = next));

    ref.onDispose(controller.dispose);
    return controller;
  },
);

class DemoNode extends TreeNode<DemoNode> {
  static int _autoIncrementedId = 0;
  static final root = DemoNode(id: -1, label: '/');

  DemoNode({
    int? id,
    required this.label,
    super.isExpanded = false,
    List<DemoNode>? children,
  })  : id = id ?? _autoIncrementedId++,
        _children = children ?? <DemoNode>[] {
    for (final child in _children) {
      child._parent = this;
    }
  }

  final String label;

  @override
  final int id;

  @override
  UnmodifiableListView<DemoNode> get children {
    return UnmodifiableListView(_children);
  }

  final List<DemoNode> _children;

  bool get isLeaf => _children.isEmpty;

  DemoNode? get parent => _parent;
  DemoNode? _parent;

  int get index => _parent?._children.indexOf(this) ?? 0;

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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<String>('label', label));
  }
}
