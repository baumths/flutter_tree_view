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

class _TreeReorderingDetails<T extends Object> {
  _TreeReorderingDetails({
    required this.index,
    required this.node,
    required this.path,
  });

  final int index;
  final T node;
  final List<T> path;

  Offset pointerDelta = Offset.zero;
}

class _SliverReorderableTreeState<T extends Object>
    extends State<SliverReorderableTree<T>> {
  List<TreeEntry<T>> _flatTree = const [];
  late Map<int, TreeEntry<T>> _temporaryOverrides = {};
  late Map<int, TreeEntry<T>> _permanentOverrides = {};

  TreeEntry<T> _entryAt(int index) {
    return _temporaryOverrides[index] ??
        _permanentOverrides[index] ??
        _flatTree[index];
  }

  void _updateFlatTree() {
    final List<TreeEntry<T>> flatTree = <TreeEntry<T>>[];
    widget.controller.depthFirstTraversal(onTraverse: flatTree.add);
    _flatTree = flatTree;
  }

  void _rebuild() => setState(_updateFlatTree);

  // This ValueNotifier is used to update the TreeEntry properties of the
  // dragging node so it shows the proper indent & guides while moving around.
  late final ValueNotifier<TreeEntry<T>?> _draggingEntryNotifier;
  _TreeReorderingDetails<T>? _details;
  int? _insertIndex;

  List<T> _getFullPath(TreeEntry<T> entry) {
    final List<T> path = <T>[entry.node];
    TreeEntry<T>? current = entry.parent;

    while (current != null) {
      path.insert(0, current.node);
      current = current.parent;
    }

    return path;
  }

  TreeEntry<T>? _getEntryAbove(int index) {
    assert(_details != null);

    if (index < 1) return null;

    final TreeEntry<T> entry = _entryAt(index - 1);

    if (entry.node == _details!.node) {
      return _getEntryAbove(index - 1);
    }

    return entry;
  }

  void _onReorderStart(int index) {
    assert(_details == null);
    TreeEntry<T> draggingEntry = _entryAt(index);

    setState(() {
      _details = _TreeReorderingDetails<T>(
        index: index,
        node: draggingEntry.node,
        path: _getFullPath(draggingEntry),
      );

      if (widget.controller.getExpansionState(draggingEntry.node)) {
        widget.controller.setExpansionState(draggingEntry.node, false);
        _updateFlatTree();

        final TreeEntry<T> newEntry = _entryAt(index);
        assert(
          newEntry.node == draggingEntry.node,
          'Index of a node must not change when it is collapsed.',
        );
        draggingEntry = newEntry;
        _draggingEntryNotifier.value = draggingEntry;
      }

      if (index > 0 && !draggingEntry.hasNextSibling) {
        final TreeEntry<T> previousEntry = _flatTree[index - 1];

        if (_areSiblings(previousEntry, draggingEntry)) {
          _permanentOverrides[index - 1] = previousEntry.copyWith(
            parent: () => previousEntry.parent,
            hasNextSibling: false,
          );
        }
      }
    });
  }

  bool _areSiblings(TreeEntry<T> a, TreeEntry<T> b) {
    return a.level == b.level && a.parent?.node == b.parent?.node;
  }

  void _updateVirtualEntries(int insertIndex) {
    assert(_details != null);

    _temporaryOverrides.clear();

    final TreeEntry<T> draggingEntry = _entryAt(_details!.index);
    final TreeEntry<T>? entryAbove = _getEntryAbove(insertIndex);

    if (entryAbove == null) {
      _draggingEntryNotifier.value = draggingEntry.copyWith(
        parent: null,
        level: 0,
        isExpanded: false,
        hasNextSibling: _details!.node != _flatTree[1].node,
      );
    } else {
      final TreeEntry<T>? newParent;
      final int newLevel;
      final bool newHasNextSibling;

      if (entryAbove.isExpanded) {
        // `draggingEntry` will become the first child of `entryAbove`

        newParent = entryAbove;
        newLevel = entryAbove.level + 1;
        newHasNextSibling = entryAbove.hasChildren;
      } else {
        // `draggingEntry` will become the next sibling of `entryAbove`

        newParent = entryAbove.parent;
        newLevel = entryAbove.level;
        newHasNextSibling = entryAbove.hasNextSibling;

        _temporaryOverrides[entryAbove.index] = entryAbove.copyWith(
          parent: () => entryAbove.parent,
          hasNextSibling: true,
        );
      }

      _draggingEntryNotifier.value = draggingEntry.copyWith(
        parent: () => newParent,
        level: newLevel,
        index: insertIndex,
        isExpanded: false,
        hasNextSibling: newHasNextSibling,
      );
    }
  }

  void _onReorderMove(int insertIndex) {
    assert(_details != null);

    setState(() {
      _updateVirtualEntries(insertIndex);
      _insertIndex = insertIndex;
    });
  }

  void _onReorderEnd(int index) {
    _details = null;
    _insertIndex = null;
    _temporaryOverrides.clear();
    _permanentOverrides.clear();
  }

  void _onReorder(int oldIndex, int newIndex) {
    // TODO: find new node location in the tree
    // widget.onReorder(...);

    _rebuild();
    _draggingEntryNotifier.value = null;
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _updateFlatTree();
    _draggingEntryNotifier = ValueNotifier<TreeEntry<T>?>(null);
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
    _temporaryOverrides = const {};
    _permanentOverrides = const {};
    _draggingEntryNotifier.dispose();
    _details = null;
    _insertIndex = null;
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
        final TreeEntry<T> entry = _entryAt(index);

        return _ReorderableTreeEntry<T>(
          key: _ReorderableTreeEntryGlobalKey<T>(entry.node, this),
          entry: entry,
          builder: widget.nodeBuilder,
          draggingEntryNotifier: _draggingEntryNotifier,
        );
      },
    );
  }
}

class _ReorderableTreeEntry<T extends Object> extends StatelessWidget {
  const _ReorderableTreeEntry({
    super.key,
    required this.entry,
    required this.builder,
    required this.draggingEntryNotifier,
  });

  final TreeEntry<T> entry;
  final TreeNodeBuilder<T> builder;
  final ValueNotifier<TreeEntry<T>?> draggingEntryNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TreeEntry<T>?>(
      valueListenable: draggingEntryNotifier,
      builder: (
        BuildContext context,
        TreeEntry<T>? draggingEntry,
        Widget? child,
      ) {
        if (draggingEntry != null &&
            draggingEntry != entry &&
            draggingEntry.node == entry.node) {
          return builder(context, draggingEntry);
        }
        return child!;
      },
      child: builder(context, entry),
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

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableTreeEntryGlobalKey<T extends Object> extends GlobalObjectKey {
  const _ReorderableTreeEntryGlobalKey(this.node, this.state) : super(node);

  final T node;
  final _SliverReorderableTreeState<T> state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ReorderableTreeEntryGlobalKey<T> &&
        other.node == node &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(node, state);
}

extension<T extends Object> on TreeEntry<T> {
  TreeEntry<T> copyWith({
    TreeEntry<T>? Function()? parent,
    T? node,
    int? index,
    int? level,
    bool? isExpanded,
    bool? hasChildren,
    bool? hasNextSibling,
  }) {
    return TreeEntry<T>(
      parent: parent != null ? parent() : this.parent,
      node: node ?? this.node,
      index: index ?? this.index,
      level: level ?? this.level,
      isExpanded: isExpanded ?? this.isExpanded,
      hasChildren: hasChildren ?? this.hasChildren,
      hasNextSibling: hasNextSibling ?? this.hasNextSibling,
    );
  }
}
