import 'package:flutter/material.dart';

import 'tree_controller.dart';

// Examples can assume:
//
// class Node {
//   Node(this.children);
//   List<Node> children;
// }
//
// final TreeController<Node> treeController = TreeController<Node>(
//   root: <Node>[
//     Node(<Node>[]),
//   ],
//   childrenProvider: (Node node) => node.children,
// );

/// Signature of a widget builder function for tree views.
typedef TreeNodeBuilder<T extends Object> = Widget Function(
  BuildContext context,
  TreeEntry<T> entry,
);

/// A wrapper around [SliverList] that adds basic tree viewing capabilities.
///
/// Usage:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return CustomScrollView(
///     slivers: [
///       SliverTree<Node>(
///         controller: treeController,
///         nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
///           ...
///         },
///       ),
///     ],
///   );
/// }
/// ```
///
/// See also:
/// * [TreeView], which covers the [CustomScrollView] boilerplate.
/// * [AnimatedTreeView], a [TreeView] that animates the expansion state changes
///   of tree nodes.
class SliverTree<T extends Object> extends StatefulWidget {
  /// Creates a [SliverTree].
  const SliverTree({
    super.key,
    required this.controller,
    required this.nodeBuilder,
  });

  /// {@template flutter_fancy_tree_view.SliverTree.controller}
  /// The object responsible for providing access to tree nodes and their states.
  ///
  /// This widget will listen to the notifications of this controller and
  /// rebuild the internal flat represetantion of the tree to make sure the
  /// presented tree view is always up to date.
  /// {@endtemplate}
  final TreeController<T> controller;

  /// {@template flutter_fancy_tree_view.SliverTree.nodeBuilder}
  /// Callback used to map tree nodes into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds,
  /// like the index, level, expansion state, parent, etc.
  /// {@endtemplate}
  final TreeNodeBuilder<T> nodeBuilder;

  @override
  State<SliverTree<T>> createState() => _SliverTreeState<T>();
}

class _SliverTreeState<T extends Object> extends State<SliverTree<T>> {
  List<TreeEntry<T>> _flatTree = const [];

  void _updateFlatTree() {
    final List<TreeEntry<T>> flatTree = [];
    widget.controller.depthFirstTraversal(onTraverse: flatTree.add);
    _flatTree = flatTree;
  }

  void _rebuild() => setState(_updateFlatTree);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _updateFlatTree();
  }

  @override
  void didUpdateWidget(covariant SliverTree<T> oldWidget) {
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
    return TreeViewScope<T>(
      controller: widget.controller,
      child: SliverList.builder(
        itemCount: _flatTree.length,
        itemBuilder: (BuildContext context, int index) {
          return widget.nodeBuilder(context, _flatTree[index]);
        },
      ),
    );
  }
}

/// An [InheritedWidget] responsible for providing some information about a
/// [TreeView] for descendant widgets.
///
/// This widget will be added to the widget tree by [SliverTree] and
/// [SliverAnimtedTree] so descendant widgets can have access to some tree
/// properties like the [TreeController].
///
/// Both [TreeDraggable] and [TreeDragTarget] will use this widget to access
/// the [TreeController] when needed for some drag and drop features like auto
/// toggle expansion on hover.
class TreeViewScope<T extends Object> extends InheritedWidget {
  /// Creates a [TreeViewScope].
  const TreeViewScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The object responsible for providing access to tree nodes, their
  /// hierarchies and states.
  final TreeController<T> controller;

  /// The closest instance of [TreeViewScope] that encloses the given context,
  /// or null if none is found.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// TreeViewScope<T>? treeViewScope = TreeViewScope.maybeOf<T>(context);
  /// ```
  ///
  /// Calling this method will create a dependency on the closest
  /// [TreeViewScope] in the [context], if there is one.
  ///
  /// See also:
  ///
  /// * [TreeViewScope.of], which is similar to this method, but asserts if no
  ///   [TreeViewScope] ancestor is found.
  static TreeViewScope<T>? maybeOf<T extends Object>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TreeViewScope<T>>();
  }

  /// The closest instance of [TreeViewScope] that encloses the given context.
  ///
  /// If no instance is found, this method will assert in debug mode and throw
  /// an exception in release mode.
  ///
  /// Calling this method will create a dependency on the closest
  /// [TreeViewScope] in the [context].
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// TreeViewScope<T> treeViewScope = TreeViewScope.of<T>(context);
  /// ```
  ///
  /// See also:
  ///
  /// * [TreeViewScope.maybeOf], which is similar to this method, but returns
  ///   null if no [TreeViewScope] ancestor is found.
  static TreeViewScope<T> of<T extends Object>(BuildContext context) {
    final TreeViewScope<T>? scope = maybeOf<T>(context);
    assert(() {
      if (scope == null) {
        throw FlutterError(
          'TreeViewScope.of() was called with a context that does not contain '
          'a TreeViewScope widget.\n'
          'No TreeViewScope widget ancestor could be found starting from the '
          'context that was passed to TreeViewScope.of(). This can happen '
          'because you are using a widget that looks for a TreeViewScope '
          'ancestor, but no such ancestor exists.\n'
          'The context used was:\n'
          '  $context',
        );
      }
      return true;
    }());
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant TreeViewScope<T> oldWidget) {
    return oldWidget.controller != controller;
  }
}
