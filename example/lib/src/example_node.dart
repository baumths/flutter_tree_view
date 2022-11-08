import 'dart:collection' show UnmodifiableListView;

import 'package:flutter/widgets.dart' show FocusNode;
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class ExampleNode extends ParentedTreeNode<ExampleNode> {
  static int _autoIncrementedId = 0;

  ExampleNode({
    required this.label,
    super.isExpanded,
    List<ExampleNode>? children,
  })  : id = _autoIncrementedId++,
        _children = children ?? [] {
    _children.forEach(_reparent);
  }

  @override
  final int id;

  final String label;

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

  bool get isHighlighted => focusNode.hasFocus;

  final FocusNode focusNode = FocusNode();

  void dispose() {
    focusNode.dispose();
  }

  void visitDescendants(void Function(ExampleNode descendant) visit) {
    visit(this);
    for (final ExampleNode child in _children) {
      child.visitDescendants(visit);
    }
  }

  static ExampleNode createSampleTree() {
    return ExampleNode(
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
    );
  }
}
