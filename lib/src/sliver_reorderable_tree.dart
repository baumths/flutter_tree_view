// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'custom_sliver_reorderable_list.dart';
import 'sliver_tree.dart';
import 'tree_controller.dart';

typedef TreeReorderNodeProxyDecorator<T extends Object> = Widget Function(
  Widget child,
  TreeEntry<T> entry,
  Animation<double> animation,
);

class SliverReorderableTree<T extends Object> extends SliverTree<T> {
  const SliverReorderableTree({
    super.key,
    required super.controller,
    required super.nodeBuilder,
    this.proxyDecorator,
  });

  final TreeReorderNodeProxyDecorator<T>? proxyDecorator;

  @override
  State<SliverReorderableTree<T>> createState() =>
      _SliverReorderableTreeState<T>();
}

class _SliverReorderableTreeState<T extends Object>
    extends State<SliverReorderableTree<T>> {
  List<TreeEntry<T>> _flatTree = const [];
  TreeEntry<T> _entryAt(int index) => _flatTree[index];

  void _updateFlatTree() {
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
    // TODO: make sure to NOT descend into the subtree of the node being dragged
    //       since it must remain collapsed for the duration of the drag.
    widget.controller.depthFirstTraversal(onTraverse: flatTree.add);
    _flatTree = flatTree;
  }

  void _rebuild() => setState(_updateFlatTree);

  void _onReorderStart(int index) {
    widget.controller.collapse(_entryAt(index).node);
  }

  void _onReorderMove(int index) {
    // TODO: update proxy TreeEntry instances to show virtual hierarchy
  }

  void _onReorderEnd(int index) {
    // TODO
  }

  void _onReorder(int oldIndex, int newIndex) {
    // TODO: find new node location in the tree
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _updateFlatTree();
  }

  @override
  void didUpdateWidget(covariant SliverReorderableTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_rebuild);
      widget.controller.addListener(_rebuild);
      _updateFlatTree();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _flatTree = const [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverCustomReorderableList(
      itemCount: _flatTree.length,
      onReorderStart: _onReorderStart,
      onReorderMove: _onReorderMove,
      onReorderEnd: _onReorderEnd,
      onReorder: _onReorder,
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        final TreeEntry<T> entry = _entryAt(index);
        return widget.proxyDecorator?.call(child, entry, animation) ?? child;
      },
      itemBuilder: (BuildContext context, int index) {
        return widget.nodeBuilder(context, _entryAt(index));
      },
    );
  }
}
