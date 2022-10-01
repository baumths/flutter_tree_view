import 'dart:collection' show UnmodifiableListView;

import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ExampleNode {
  static int _autoIncrementedId = 0;

  ExampleNode({
    required this.label,
    this.isExpanded = false,
    List<ExampleNode>? children,
  })  : id = _autoIncrementedId++,
        _children = children ?? [] {
    _children.forEach(_reparent);
  }

  final int id;
  final String label;

  bool isExpanded;

  UnmodifiableListView<ExampleNode> get children {
    return UnmodifiableListView(_children);
  }

  final List<ExampleNode> _children;

  bool get hasChildren => _children.isNotEmpty;

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

  @override
  String toString() {
    return 'ExampleNode(id: $id, label: $label, isExpanded: $isExpanded)';
  }
}

class ExampleTree extends Tree<ExampleNode> {
  const ExampleTree({required this.root});

  final ExampleNode root;

  @override
  List<ExampleNode> get roots => root.children;

  @override
  int getId(ExampleNode node) => node.id;

  @override
  List<ExampleNode> getChildren(ExampleNode node) => node.children;

  @override
  bool getExpansionState(ExampleNode node) => node.isExpanded;

  @override
  void setExpansionState(ExampleNode node, bool expanded) {
    node.isExpanded = expanded;
  }

  static ExampleTree createSampleTree() {
    return ExampleTree(
      root: ExampleNode(
        label: '/',
        children: [
          ExampleNode(
            label: 'Root 1',
            children: [
              ExampleNode(
                label: 'Node 1.A',
                children: [
                  ExampleNode(label: 'Node 1.A.1'),
                  ExampleNode(label: 'Node 1.A.2'),
                ],
              ),
              ExampleNode(label: 'Node 1.B'),
            ],
          ),
          ExampleNode(
            label: 'Root 2',
            children: [
              ExampleNode(
                label: 'Node 2.A',
                children: [
                  for (int index = 1; index <= 5; index++)
                    ExampleNode(label: 'Node 2.A.$index'),
                ],
              ),
              ExampleNode(label: 'Node 2.B'),
              ExampleNode(
                label: 'Node 2.C',
                children: [
                  for (int index = 1; index <= 5; index++)
                    ExampleNode(label: 'Node 2.C.$index'),
                ],
              ),
              ExampleNode(label: 'Node 2.D'),
            ],
          ),
          ExampleNode(label: 'Root 3'),
        ],
      ),
    );
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('ExampleTree(');

    flatten(
      startingLevel: 1,
      descendCondition: (_) => true,
      onTraverse: (TreeEntry<ExampleNode> entry) {
        buffer.write('  ' * entry.level);
        buffer.writeln(entry.node);
      },
    );

    buffer.write(')');
    return buffer.toString();
  }
}
