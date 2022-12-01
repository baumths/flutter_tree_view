import 'dart:collection' show UnmodifiableListView;

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ExampleNode extends TreeNode<ExampleNode> {
  static int _uniqueKey = 0;

  ExampleNode({
    required this.label,
    this.isExpanded = false,
    List<ExampleNode>? children,
  })  : key = _uniqueKey++,
        _children = children ?? [] {
    _children.forEach(_reparent);
  }

  bool isExpanded;

  final String label;

  @override
  final int key;

  @override
  UnmodifiableListView<ExampleNode> get children {
    return UnmodifiableListView(_children);
  }

  final List<ExampleNode> _children;

  @override
  ExampleNode? get parent => _parent;
  ExampleNode? _parent;

  void insertChild(int index, ExampleNode child) {
    if (child.parent == this) {
      _move(child, index);
    } else {
      _reparent(child);
      _children.insert(index, child);
    }
  }

  void removeChild(ExampleNode child) {
    if (_children.remove(child)) {
      child._parent = null;
    }
  }

  void _move(ExampleNode child, int newIndex) {
    final int oldIndex = _children.indexOf(child);

    if (newIndex > oldIndex) {
      --newIndex;
    }

    if (newIndex == oldIndex) return;

    _children
      ..removeAt(oldIndex)
      ..insert(newIndex, child);
  }

  void _reparent(ExampleNode child) {
    child._parent?.removeChild(child);
    child._parent = this;
  }
}

class ExampleTreeController extends TreeController<ExampleNode> {
  @override
  bool getExpansionState(ExampleNode node) {
    return node.isExpanded;
  }

  @override
  void setExpansionState(ExampleNode node, bool expanded) {
    node.isExpanded = expanded;
  }
}

typedef NodeFactory<T extends Object> = T Function({
  required String label,
  List<T>? children,
});

T createSampleTree<T extends Object>(NodeFactory<T> nodeFactory) {
  return nodeFactory(
    label: '/',
    children: [
      nodeFactory(
        label: 'Root 1',
        children: [
          nodeFactory(
            label: 'Node 1.A',
            children: [
              nodeFactory(label: 'Node 1.A.1'),
              nodeFactory(label: 'Node 1.A.2'),
            ],
          ),
          nodeFactory(label: 'Node 1.B'),
        ],
      ),
      nodeFactory(
        label: 'Root 2',
        children: [
          nodeFactory(
            label: 'Node 2.A',
            children: [
              for (int index = 1; index <= 5; index++)
                nodeFactory(label: 'Node 2.A.$index'),
            ],
          ),
          nodeFactory(label: 'Node 2.B'),
          nodeFactory(
            label: 'Node 2.C',
            children: [
              for (int index = 1; index <= 5; index++)
                nodeFactory(label: 'Node 2.C.$index'),
            ],
          ),
          nodeFactory(label: 'Node 2.D'),
        ],
      ),
      nodeFactory(label: 'Root 3'),
    ],
  );
}
