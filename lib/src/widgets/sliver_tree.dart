import 'dart:math' as math show min;

import 'package:flutter/material.dart';

import '../foundation.dart';
import 'tree_indentation.dart' show TreeIndentDetailsScope;

/// Signature for a function that creates a widget for a given tree node, e.g.,
/// in a tree view.
typedef TreeNodeBuilder<T extends Object> = Widget Function(
  BuildContext context,
  TreeEntry<T> entry,
);

/// Signature for a function that takes a widget and an animation to apply
/// transitions if needed.
typedef TreeTransitionBuilder = Widget Function(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

/// The default transition builder used by [SliverTree] to animate the expansion
/// state changes of a tree node.
///
/// By default, wraps [child] with a [SizeTransition].
Widget defaultTreeTransitionBuilder(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  return SizeTransition(
    sizeFactor: animation,
    child: child,
  );
}

/// A wrapper around [SliverList] that adds tree viewing capabilities.
///
/// Usage:
/// ```dart
/// class Node {
///   Node(this.title) : children = <Node>[];
///   String title;
///   List<Node> chilren;
/// }
///
/// class MyTreeView extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return CustomScrollView(
///       slivers: [
///         SliverTree<Node>(
///           roots: [Node('Root')],
///           childrenProvider: (Node node) => node.children,
///           nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
///             return MyTreeTile(entry: entry);
///           },
///         ),
///       ],
///     );
///   }
/// }
///
/// class MyTreeTile extends StatelessWidget {
///   const MyTreeTile({super.key, required this.entry});
///
///   final TreeEntry<Node> entry;
///
///   @override
///   Widget build(BuildContext context) {
///     return TreeIndentation(
///       child: Row(
///         children: [
///           FolderButton(
///             isOpen: entry.isExpanded,
///             onPressed: () {
///               SliverTree.of<Node>(context).toggleExpansion(entry.node);
///             },
///           ),
///           Flexible(
///             child: Text(entry.node.title),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
///
/// See also:
/// * [TreeView], which covers the [CustomScrollView] boilerplate.
class SliverTree<T extends Object> extends StatefulWidget {
  /// Creates a [SliverTree].
  const SliverTree({
    super.key,
    required this.roots,
    required this.childrenProvider,
    this.controller,
    required this.nodeBuilder,
    this.transitionBuilder = defaultTreeTransitionBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.linear,
    this.maxNodesToShowWhenAnimating = 50,
    this.rootLevel = defaultTreeRootLevel,
  })  : assert(maxNodesToShowWhenAnimating > 0),
        assert(roots.length > 0, 'At least one root node must be provided.');

  /// The roots of the tree.
  ///
  /// When flattening the tree, each node in this iterable will become a root
  /// of its subtree, which will be collected using [childrenProvider].
  final Iterable<T> roots;

  /// {@template flutter_fancy_tree_view.SliverTree.childrenProvider}
  /// A callback used when building the flat representation of the tree to get
  /// the direct children of the tree node passed to it.
  ///
  /// Avoid doing heavy computations in this callback since it is going to be
  /// called a lot when traversing the tree.
  ///
  /// Do not attempt to load the children of a node in this callback as it would
  /// significantly slow down tree traversal which might couse ui jank. Prefer
  /// doing such operations on a user action (e.g. a button press).
  ///
  /// Example using nested objects:
  /// ```dart
  /// class Node {
  ///   List<Node> children;
  /// }
  ///
  /// Iterable<Node> childrenProvider(Node node) => node.children;
  /// ```
  ///
  /// Example using a Map cache:
  /// ```dart
  /// class Data {
  ///   final int id;
  /// }
  ///
  /// final Map<int, List<Data>> childrenCache = <int, List<Data>>{};
  ///
  /// Iterable<Data> childrenProvider(Data parent) {
  ///   return childrenCache[parent.id] ?? const Iterable.empty();
  /// },
  /// ```
  /// {@endtemplate}
  final ChildrenProvider<T> childrenProvider;

  /// An object that can be used to control the state of the tree.
  ///
  /// Whenever this controller notifies its listeners, the internal flat
  /// representation of the tree will be rebuilt.
  final TreeController<T>? controller;

  /// Callback used to map tree nodes into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds.
  final TreeNodeBuilder<T> nodeBuilder;

  /// A widget builder used to apply a transition to the expansion state changes
  /// of a node subtree when animations are enabled.
  ///
  /// See also:
  ///
  /// * [defaultTreeTransitionBuilder] which uses a [SizeTransition].
  final TreeTransitionBuilder transitionBuilder;

  /// The default duration to use when animating the expand/collapse operations.
  ///
  /// Provide an [animationDuration] of `Duration.zero` to disable animations.
  ///
  /// Defaults to `Duration(milliseconds: 300)`.
  final Duration animationDuration;

  /// The default curve to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Curves.linear`.
  final Curve animationCurve;

  /// {@template flutter_fancy_tree_view.SliverTree.maxNodesToShowWhenAnimating}
  /// The amount of nodes that are going to be shown on an animating subtree.
  ///
  /// Must be greater than `0`.
  ///
  /// When animating the expand/collapse state changes, all descendant nodes
  /// whose visibility will change are rendered along with the toggled node,
  /// i.e. a [Column] is used, therefore rendering the entire subtree regardless
  /// of being a "lazy" rendered view.
  ///
  /// This value can be used to limit how many nodes are actually rendered
  /// during the animation, since there could be cases where not all widgets
  /// are visible due to scroll offsets.
  ///
  /// Defaults to `50`.
  /// {@endtemplate}
  final int maxNodesToShowWhenAnimating;

  /// {@template flutter_fancy_tree_view.SliverTree.rootLevel}
  /// Used when flattening the tree to determine the level of root nodes.
  ///
  /// Must be a positive integer.
  ///
  /// Can be used to increase the indentation of nodes, if set to `1` root nodes
  /// will have 1 level of indentation and lines will be painted at root level
  /// (if line painting is enabled), if set to `0` ([rootLevel])
  /// root nodes won't have any indentation and no lines will be painted for
  /// them.
  ///
  /// The higher the root level, more [IndentGuide.indent] is going to be added
  /// to the indentation of a node.
  ///
  /// Defaults to [rootLevel], usual values are `0` or `1`.
  /// {@endtemplate}
  final int rootLevel;

  /// The [SliverTree] from the closest instance of this class that encloses the
  /// given context.
  ///
  /// If there is no [SliverTree] ancestor in the widget tree at the given
  /// context, then this will return null.
  ///
  /// Typical usage is as follows:
  ///
  /// SliverTreeState<T>? treeState = SliverTree.maybeOf<T>(context);
  ///
  /// See also:
  ///
  ///  * [of], which will throw in debug mode if no [SliverTree] ancestor exists
  ///    in the widget tree.
  static SliverTreeState<T>? maybeOf<T extends Object>(BuildContext context) {
    return context.findAncestorStateOfType<SliverTreeState<T>>();
  }

  /// The [SliverTree] from the closest instance of this class that encloses the
  /// given context.
  ///
  /// If there is no [SliverTree] ancestor in the widget tree at the given
  /// context, then this will throw in debug mode.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SliverTreeState<T> treeState = SliverTree.of<T>(context);
  /// ```
  ///
  /// See also:
  ///
  ///  * [maybeOf], which will return null if no [SliverTree] ancestor exists in
  ///    the widget tree.
  static SliverTreeState<T> of<T extends Object>(BuildContext context) {
    final SliverTreeState<T>? instance = maybeOf<T>(context);
    assert(() {
      if (instance == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverTree.of() called with a context that does not contain a '
            'SliverTree.',
          ),
          ErrorDescription(
            'No SliverTree ancestor could be found starting from the context '
            'that was passed to SliverTree.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same '
            'StatefulWidget that built the SliverTree.',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return instance!;
  }

  @override
  State<SliverTree<T>> createState() => SliverTreeState<T>();
}

/// The object that holds the state of a [SliverTree].
///
/// This state object can be obtained by [SliverTree.of] and [SliverTree.maybeOf]
/// to execute some actions on the current state of the tree (e.g. to toggle
/// the expansion state of a node, etc.).
class SliverTreeState<T extends Object> extends State<SliverTree<T>>
    with TreeFlattener<T> {
  /// The controller responsible for providing expansion state of tree nodes.
  TreeController<T> get controller => widget.controller ?? _fallbackController!;
  TreeController<T>? _fallbackController;

  void _rebuild({bool animate = true}) {
    setState(() => _updateFlatTree(animate: animate));
  }

  void _disposeFallbackController() {
    _fallbackController
      ?..removeListener(_rebuild)
      ..dispose();
    _fallbackController = null;
  }

  @override
  Iterable<T> get roots => widget.roots;

  @override
  ChildrenProvider<T> get childrenProvider => widget.childrenProvider;

  @override
  bool getExpansionState(T node) => controller.expansionState.get(node);

  /// The most recent tree flattened from [SliverTree.roots].
  Iterable<TreeEntry<T>> get flatTree => _flatTree;
  List<TreeEntry<T>> _flatTree = const [];

  /// Returns the [TreeEntry] at the given [index] of the current [flatTree].
  TreeEntry<T> entryAt(int index) => _flatTree[index];

  TreeEntry<T>? _entryOf(T node) => _entryByNodeCache[node];
  final Map<T, TreeEntry<T>> _entryByNodeCache = <T, TreeEntry<T>>{};

  final Set<T> _animatingNodes = <T>{};

  void _onAnimationComplete(T node) {
    _animatingNodes.remove(node);
    _rebuild(animate: false);
  }

  void _updateFlatTree({bool animate = true}) {
    Visitor<TreeEntry<T>> onTraverse;

    if (animate && widget.animationDuration != Duration.zero) {
      final Map<T, TreeEntry<T>> oldEntries = Map.of(_entryByNodeCache);

      onTraverse = (TreeEntry<T> entry) {
        _entryByNodeCache[entry.node] = entry;
        final TreeEntry<T>? oldEntry = oldEntries[entry.node];

        if (oldEntry != null && oldEntry.isExpanded != entry.isExpanded) {
          _animatingNodes.add(entry.node);
        }
      };
    } else {
      onTraverse = (TreeEntry<T> entry) {
        _entryByNodeCache[entry.node] = entry;
      };
    }

    _entryByNodeCache.clear();

    final List<TreeEntry<T>> flatTree = buildFlatTree(
      rootLevel: widget.rootLevel,
      onTraverse: onTraverse,
      descendCondition: (TreeEntry<T> entry) {
        if (_animatingNodes.contains(entry.node)) {
          // The descendants of a node that is animating are not included in the
          // flattened tree since those nodes are going to be rendered in a
          // single tile.
          return false;
        }
        return entry.isExpanded;
      },
    );

    _flatTree = flatTree;
  }

  /// Updates [node]'s expansion state to the opposite state and rebuilds the
  /// tree.
  void toggleExpansion(T node, {bool animate = true}) {
    controller.expansionState.set(node, !controller.expansionState.get(node));
    _rebuild(animate: animate);
  }

  //* REORDERING ---------------------------------------------------------------

  Rect _autoScrollRect = Rect.zero;
  EdgeDraggingAutoScroller? _autoScroller;

  void _handleScrollableAutoScrolled() {
    if (_autoScrollRect == Rect.zero) return;
    // Continue scrolling if the drag is still in progress.
    _autoScroller?.startAutoScrollIfNecessary(_autoScrollRect);
  }

  /// Starts scrolling the ancestor [Scrollable] if [rect] is close enough to
  /// the vertical edges of the scrollable's viewport.
  ///
  /// Used by [TreeDraggable] to auto scroll when dragging.
  void startAutoScrollIfNecessary(Rect rect) {
    _autoScrollRect = rect;
    _autoScroller?.startAutoScrollIfNecessary(_autoScrollRect);
  }

  /// Stops scrolling the ancestor [Scrollable].
  ///
  /// Used by [TreeDraggable] when stopped dragging.
  void stopAutoScroll() {
    _autoScroller?.stopAutoScroll();
    _autoScrollRect = Rect.zero;
  }

  /// An unordered set of tree nodes composed by the node being dragged (if any)
  /// and all its ancestor nodes. Returns an empty set if no node is currenlty
  /// being dragged.
  ///
  /// Used by [TreeDragTarget] to avoid collapsing the ancestors of a dragging
  /// node.
  Iterable<T> get draggingNodePath => _draggingNodePath;
  Set<T> _draggingNodePath = const {};

  /// Called by [TreeDraggable] when it starts dragging to make sure that the
  /// dragged node stays visible during the drag gesture by disabling auto
  /// toggle expansion.
  ///
  /// This should not be used from outside of [TreeDraggable].
  void onNodeDragStarted(T node) {
    final TreeEntry<T>? entry = _entryOf(node);
    if (entry == null) return;

    final Set<T> path = <T>{node};

    TreeEntry<T>? current = entry.parent;
    while (current != null) {
      path.add(current.node);
      current = current.parent;
    }

    _draggingNodePath = path;
  }

  /// Called by [TreeDraggable] when it stops dragging to clear [draggingNodePath].
  ///
  /// This should not be used from outside of [TreeDraggable].
  void onNodeDragEnded() {
    _draggingNodePath = const {};
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _fallbackController = TreeController<T>();
    }

    controller.addListener(_rebuild);
    _updateFlatTree(animate: false);
  }

  @override
  void didUpdateWidget(covariant SliverTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        assert(_fallbackController != null);
        assert(widget.controller != null);
        _disposeFallbackController();
      } else {
        oldWidget.controller?.removeListener(_rebuild);
        if (widget.controller == null) {
          _fallbackController = TreeController<T>();
        }
      }
      controller.addListener(_rebuild);
    }

    if (oldWidget.roots != roots ||
        oldWidget.childrenProvider != childrenProvider ||
        oldWidget.rootLevel != widget.rootLevel) {
      _updateFlatTree();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ScrollableState scrollable = Scrollable.of(context);

    if (_autoScroller?.scrollable != scrollable) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = EdgeDraggingAutoScroller(
        scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
      );
    }
  }

  @override
  void dispose() {
    stopAutoScroll();
    widget.controller?.removeListener(_rebuild);
    _disposeFallbackController();
    _autoScrollRect = Rect.zero;
    _entryByNodeCache.clear();
    _flatTree = const [];
    _draggingNodePath = const {};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        _nodeBuilder,
        childCount: _flatTree.length,
      ),
    );
  }

  Widget _wrapWithDetails(BuildContext context, TreeEntry<T> entry) {
    return TreeIndentDetailsScope(
      details: entry,
      child: Builder(
        builder: (BuildContext context) => widget.nodeBuilder(context, entry),
      ),
    );
  }

  Widget _nodeBuilder(BuildContext context, int index) {
    final TreeEntry<T> entry = entryAt(index);

    return _TreeEntry<T>(
      key: _SaltedTreeEntryKey(entry.node),
      entry: entry,
      treeFlattener: this,
      nodeBuilder: _wrapWithDetails,
      transitionBuilder: widget.transitionBuilder,
      onAnimationComplete: _onAnimationComplete,
      maxNodesToShow: widget.maxNodesToShowWhenAnimating,
      curve: widget.animationCurve,
      duration: widget.animationDuration,
      shouldAnimate: _animatingNodes.contains(entry.node),
    );
  }
}

class _SaltedTreeEntryKey extends GlobalObjectKey {
  const _SaltedTreeEntryKey(super.value);
}

class _TreeEntry<T extends Object> extends StatefulWidget {
  const _TreeEntry({
    super.key,
    required this.entry,
    required this.treeFlattener,
    required this.nodeBuilder,
    required this.transitionBuilder,
    required this.onAnimationComplete,
    required this.maxNodesToShow,
    required this.curve,
    required this.duration,
    required this.shouldAnimate,
  });

  final TreeEntry<T> entry;
  final TreeFlattener<T> treeFlattener;

  final TreeNodeBuilder<T> nodeBuilder;

  final TreeTransitionBuilder transitionBuilder;
  final ValueSetter<T> onAnimationComplete;
  final int maxNodesToShow;
  final Curve curve;
  final Duration duration;
  final bool shouldAnimate;

  @override
  State<_TreeEntry<T>> createState() => _TreeEntryState<T>();
}

class _TreeEntryState<T extends Object> extends State<_TreeEntry<T>>
    with SingleTickerProviderStateMixin {
  TreeEntry<T> get entry => widget.entry;
  T get node => entry.node;

  late final AnimationController animationController;
  late final CurveTween curveTween = CurveTween(curve: Curves.ease);

  bool isExpanded = false;

  void onAnimationComplete() {
    widget.onAnimationComplete(node);
    if (!mounted) return;
    setState(() {});
  }

  void expand() {
    // Sometimes when [isExpanded] changes and [widget.shouldAnimate] is set to
    // `false`, the animation value is not reset, then later when a subsequent
    // animation starts, the controller is already completed and no animation
    // is played at all.
    final double? from = animationController.value == 1.0 ? 0.0 : null;
    animationController.forward(from: from).whenComplete(onAnimationComplete);
  }

  void collapse() {
    // Sometimes when [isExpanded] changes and [widget.shouldAnimate] is set to
    // `false`, the animation value is not reset, then later when a subsequent
    // animation starts, the controller is already completed and no animation
    // is played at all.
    final double? from = animationController.value == 0.0 ? 1.0 : null;
    animationController.reverse(from: from).whenComplete(onAnimationComplete);
  }

  @override
  void initState() {
    super.initState();
    isExpanded = widget.treeFlattener.getExpansionState(node);

    curveTween.curve = widget.curve;
    animationController = AnimationController(
      vsync: this,
      value: isExpanded ? 1.0 : 0.0,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(covariant _TreeEntry<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    curveTween.curve = widget.curve;
    animationController.duration = widget.duration;

    final bool expansionState = widget.treeFlattener.getExpansionState(node);

    if (isExpanded != expansionState) {
      isExpanded = expansionState;

      if (widget.shouldAnimate) {
        isExpanded ? expand() : collapse();
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget tile = widget.nodeBuilder(context, entry);

    if (widget.shouldAnimate || animationController.isAnimating) {
      final Widget subtree = _Subtree<T>(
        virtualRoot: entry,
        treeFlattener: widget.treeFlattener,
        nodeBuilder: widget.nodeBuilder,
        maxNodesToShow: widget.maxNodesToShow,
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile,
          widget.transitionBuilder(
            context,
            subtree,
            animationController.drive(curveTween),
          ),
        ],
      );
    }

    return tile;
  }
}

class _Subtree<T extends Object> extends StatefulWidget {
  const _Subtree({
    super.key,
    required this.virtualRoot,
    required this.treeFlattener,
    required this.nodeBuilder,
    required this.maxNodesToShow,
  });

  final TreeEntry<T> virtualRoot;
  final TreeFlattener<T> treeFlattener;
  final TreeNodeBuilder<T> nodeBuilder;
  final int maxNodesToShow;

  @override
  State<_Subtree<T>> createState() => _SubtreeState<T>();
}

class _SubtreeState<T extends Object> extends State<_Subtree<T>> {
  TreeEntry<T> get virtualRoot => widget.virtualRoot;

  late List<TreeEntry<T>> virtualEntries;
  int nodeCount = 0;

  @override
  void initState() {
    super.initState();

    final List<TreeEntry<T>> flatTree = widget.treeFlattener.buildFlatTree(
      nodes: widget.treeFlattener.childrenProvider(virtualRoot.node),
      rootLevel: virtualRoot.level + 1,
      // Apply the unreachable levels with vertical lines to make sure this
      // subtree doesn't appear floating "contextless" in the line hierarchy.
      unreachableLevelsWithVerticalLines: virtualRoot.levelsWithVerticalLines,
    );

    nodeCount = math.min(flatTree.length, widget.maxNodesToShow);
    virtualEntries = flatTree.sublist(0, nodeCount);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final TreeEntry<T> virtualEntry in virtualEntries)
            widget.nodeBuilder(context, virtualEntry),
        ],
      ),
    );
  }
}
