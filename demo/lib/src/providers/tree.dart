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
      showRoot: ref.read(showRootProvider),
    );

    ref.listen(showRootProvider, (_, bool next) => controller.showRoot = next);

    ref.listen(
      rootLevelProvider,
      (_, int next) => controller.startingLevel = next,
    );

    ref.listen(
      animatedExpansionsProvider,
      (_, bool shouldAnimate) {
        controller.animationDuration = shouldAnimate //
            ? const Duration(milliseconds: 300)
            : Duration.zero;
      },
    );

    ref.onDispose(controller.dispose);
    return controller;
  },
);

class DemoNode extends TreeNode<DemoNode> {
  static int _autoIncrementedId = 0;
  static final root = DemoNode(id: -1, label: '/', isExpanded: true);

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
  set children(Iterable<DemoNode> nodes) {
    if (hasChildren) {
      for (final child in _children) {
        child._parent = null;
      }
    }

    _children.clear();
    nodes.forEach(addChild);
  }

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
    if (_children.remove(child)) {
      child._parent = null;
    }
  }

  void _move(DemoNode child, int newIndex) {
    final int oldIndex = children.indexOf(child);

    if (newIndex > oldIndex) {
      --newIndex;
    }

    if (newIndex == oldIndex) return;

    _children
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

  static void populateDefaultTree() {
    if (root.hasChildren) return;

    root.children = [
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
}
