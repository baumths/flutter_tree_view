// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
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

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a reorderable list.
///
/// See also:
///
///  * [TreeReorderableDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [ReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [ReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class TreeReorderableDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a list item like a drag
  /// handle.
  const TreeReorderableDragStartListener({
    super.key,
    required this.child,
    required this.index,
    this.enabled = true,
  });

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a reorderable list.
  final Widget child;

  /// The index of the associated item that will be dragged in the list.
  final int index;

  /// Whether the [child] item can be dragged and moved in the list.
  ///
  /// If true, the item can be moved to another location in the list when the
  /// user taps on the child. If false, tapping on the child will be ignored.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled
          ? (PointerDownEvent event) => _startDragging(context, event)
          : null,
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a reordering
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    SliverCustomReorderableList.maybeOf(context)?.startItemDragReorder(
      index: index,
      event: event,
      recognizer: createRecognizer()
        ..gestureSettings = MediaQuery.maybeOf(context)?.gestureSettings,
    );
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the reorderable list.
///
/// See also:
///
///  * [TreeReorderableDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [ReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [ReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class TreeReorderableDelayedDragStartListener
    extends TreeReorderableDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire list item in a reorderable
  /// list.
  const TreeReorderableDelayedDragStartListener({
    super.key,
    required super.child,
    required super.index,
    super.enabled,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }
}
