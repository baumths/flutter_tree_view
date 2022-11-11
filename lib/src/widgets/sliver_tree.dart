import 'dart:collection'
    show HashMap, HashSet, UnmodifiableListView, UnmodifiableSetView;
import 'dart:math' as math show min;

import 'package:flutter/material.dart';

import '../foundation.dart';
import 'tree_indentation.dart' show TreeIndentDetailsScope;

/// Signature for a function that creates a widget for a given entry, e.g., in a
/// tree.
typedef TreeViewItemBuilder<T extends TreeNode<T>> = Widget Function(
  BuildContext context,
  TreeEntry<T> entry,
);

/// Signature for a function that takes a widget and an animation to apply
/// transitions if needed.
typedef TreeViewTransitionBuilder = Widget Function(
  BuildContext context,
  Widget child,
  Animation<double> animation,
);

/// The default transition builder used by [SliverTree] to animate the expansion
/// state changes of a node.
///
/// Wraps [child] in [SizeTransition].
Widget defaultTreeViewTransitionBuilder(
  BuildContext context,
  Widget child,
  Animation<double> animation,
) {
  return SizeTransition(
    sizeFactor: animation,
    child: child,
  );
}

/// A widget that wraps a [SliverList] adding tree viewing capabilities.
class SliverTree<T extends TreeNode<T>> extends StatefulWidget {
  /// Creates a [SliverTree].
  const SliverTree({
    super.key,
    required this.roots,
    required this.itemBuilder,
    this.transitionBuilder = defaultTreeViewTransitionBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.linear,
    this.maxNodesToShowWhenAnimating = 50,
  });

  /// The root [TreeNode]s of the tree.
  ///
  /// These nodes are used as a starting point to build the flat representation
  /// of the tree.
  final Iterable<T> roots;

  /// Callback used to map your data into widgets.
  ///
  /// The `TreeEntry<T> entry` parameter contains important information about
  /// the current tree context of the particular [TreeEntry.node] that it holds.
  final TreeViewItemBuilder<T> itemBuilder;

  /// Callback used to animate the expansion state changes of a subtree.
  ///
  /// See also:
  ///
  ///   * [defaultTreeViewTransitionBuilder] that uses a [SizeTransition].
  final TreeViewTransitionBuilder transitionBuilder;

  /// The default duration to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Duration(milliseconds: 300)`.
  final Duration animationDuration;

  /// The default curve to use when animating the expand/collapse operations.
  ///
  /// Defaults to `Curves.linear`.
  final Curve animationCurve;

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
  final int maxNodesToShowWhenAnimating;

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
  static SliverTreeState<T>? maybeOf<T extends TreeNode<T>>(
    BuildContext context,
  ) {
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
  static SliverTreeState<T> of<T extends TreeNode<T>>(BuildContext context) {
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
class SliverTreeState<T extends TreeNode<T>> extends State<SliverTree<T>> {
  /// The root [TreeNode]s of the tree.
  ///
  /// Used as a starting point to build the flat representation of the tree.
  Iterable<T> get roots => widget.roots;

  /// The most recent tree flattened from [SliverTree.roots].
  UnmodifiableListView<TreeEntry<T>> get flatTree => _flatTree;
  UnmodifiableListView<TreeEntry<T>> _flatTree = UnmodifiableListView(const []);

  /// Returns the [TreeEntry] at the given [index] of the current [flatTree].
  TreeEntry<T> entryAt(int index) => _flatTree[index];

  TreeEntry<T>? _entryOf(T node) => _entryByIdCache[node.id];
  final HashMap<Object, TreeEntry<T>> _entryByIdCache = HashMap();

  final HashSet<Object> _animatingNodes = HashSet();

  void _onAnimationComplete(T node) {
    _animatingNodes.remove(node.id);
    rebuild(animate: false);
  }

  void _updateFlatTree({bool animate = true}) {
    final Map<Object, TreeEntry<T>> oldEntries = Map.of(_entryByIdCache);
    _entryByIdCache.clear();

    final Visitor<TreeEntry<T>> onTraverse;

    if (animate) {
      onTraverse = (TreeEntry<T> entry) {
        _entryByIdCache[entry.node.id] = entry;
        final TreeEntry<T>? oldEntry = oldEntries[entry.node.id];

        if (oldEntry != null && oldEntry.isExpanded != entry.isExpanded) {
          _animatingNodes.add(entry.node.id);
        }
      };
    } else {
      onTraverse = (TreeEntry<T> entry) {
        _entryByIdCache[entry.node.id] = entry;
      };
    }

    final List<TreeEntry<T>> flatTree = roots.flatten(
      rootLevel: 0,
      onTraverse: onTraverse,
      descendCondition: (TreeEntry<T> entry) {
        if (_animatingNodes.contains(entry.node.id)) {
          // The descendants of a node that is animating are not included in the
          // flattened tree since those nodes are going to be rendered in a
          // single tile.
          return false;
        }
        return entry.node.includeChildrenWhenFlattening;
      },
    );

    _flatTree = UnmodifiableListView<TreeEntry<T>>(flatTree);
  }

  /// {@template flutter_fancy_tree_view.SliverTreeState.rebuild}
  /// Rebuilds the current flat tree.
  ///
  /// Call this method whenever the tree nodes are updated (i.e., expansion
  /// state changed, child added or removed, node reordered, etc...), so the
  /// flat tree can be refreshed to include the new changes.
  ///
  /// [animate] can be used to do an additional check when flattening to verify
  /// if a node's expansion state changed, if it did, the [TreeEntry] of that
  /// node will have its [TreeEntry.shouldAnimate] value set to `true` resulting
  /// in it being animated after this rebuild is complete.
  /// {@endtemplate}
  ///
  /// Example:
  /// ```dart
  /// class Node extends TreeNode<Node> { /* ... */ }
  ///
  /// final SliverTreeState<Node> treeState = SliverTree.of<Node>(context);
  ///
  /// // DON'T use rebuild when calling [SliverTreeState.toggleExpansion]:
  /// void toggleExpansion(Node node) {
  ///   treeState.toggleExpansion(node);
  ///   // treeState.rebuild(); // No need to call rebuild here.
  /// }
  ///
  /// // DO use rebuild when the expansion state is changed by outside sources:
  /// void toggleExpansion(Node node) {
  ///   node.isExpanded = !node.isExpanded;
  ///   treeState.rebuild(); // Call rebuild to update the tree
  /// }
  ///
  /// // DO use rebuild when nodes are added/removed/reordered:
  /// void addChild(Node parent, Node child) {
  ///   parent.children.add(child)
  ///   treeState.rebuild(animate: false);
  /// }
  ///
  /// /// Consider doing bulk updating before calling rebuild:
  /// void addChildren(Node parent, List<Node> children) {
  ///   for (final Node child in children) {
  ///     parent.children.add(child);
  ///     // DON'T rebuild after each child insertion
  ///     // treeState.rebuild();
  ///   }
  ///   // DO rebuild after all nodes are processed
  ///   treeState.rebuild(animate: false);
  /// }
  /// ```
  void rebuild({bool animate = true}) {
    setState(() => _updateFlatTree(animate: animate));
  }

  /// {@template flutter_fancy_tree_view.SliverTreeState.toggleExpansion}
  /// Updates [node]'s expansion state to the opposite state and rebuilds the
  /// tree.
  ///
  /// A check to [node.hasChildren] is done to avoid having to rebuild the tree
  /// if its structure won't change.
  ///
  /// [animate] can be used to play an expand/collapse animation when the tree
  /// is done flattening.
  /// {@endtemplate}
  void toggleExpansion(T node, {bool animate = true}) {
    node.isExpanded = !node.isExpanded;

    if (node.hasChildren) {
      rebuild(animate: animate);
    } else {
      setState(() {});
    }
  }

  //* REORDERING ---------------------------------------------------------------

  Rect _autoScrollRect = Rect.zero;
  VerticalEdgeDraggingAutoScroller? _autoScroller;

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

  /// An unordered set of node ids composed by the ids of every ancestor of the
  /// node that is currently being dragged (if any).
  /// If no node is currenlty being dragged, returns an empty set.
  ///
  /// Used by [TreeDragTarget] to avoid collapsing the ancestors of a dragging
  /// node.
  UnmodifiableSetView<Object> get draggingNodePath => _draggingNodePath;
  UnmodifiableSetView<Object> _draggingNodePath = UnmodifiableSetView(const {});

  /// Called by [TreeDraggable] when it starts dragging to make sure that the
  /// dragged node stays visible during the drag gesture by disabling auto
  /// toggle expansion.
  ///
  /// This should not be used from outside of [TreeDraggable].
  void onNodeDragStarted(T node) {
    final TreeEntry<T>? entry = _entryOf(node);
    if (entry == null) return;

    final HashSet<Object> path = HashSet()..add(node.id);

    TreeEntry<T>? current = entry.parent;
    while (current != null) {
      path.add(current.node.id);
      current = current.parent;
    }

    _draggingNodePath = UnmodifiableSetView<Object>(path);
  }

  /// Called by [TreeDraggable] when it stops dragging to clear [draggingNodePath].
  ///
  /// This should not be used from outside of [TreeDraggable].
  void onNodeDragEnded() {
    _draggingNodePath = UnmodifiableSetView(const {});
  }

  @override
  void initState() {
    super.initState();
    _updateFlatTree(animate: false);
  }

  @override
  void didUpdateWidget(covariant SliverTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.roots != widget.roots) {
      _updateFlatTree();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ScrollableState scrollable = Scrollable.of(context)!;

    if (_autoScroller?.scrollable != scrollable) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = VerticalEdgeDraggingAutoScroller(
        scrollable: scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
      );
    }
  }

  @override
  void dispose() {
    _flatTree = UnmodifiableListView(const []);
    _entryByIdCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        _itemBuilder,
        childCount: _flatTree.length,
      ),
    );
  }

  Widget _wrapWithDetails(BuildContext context, TreeEntry<T> entry) {
    return TreeIndentDetailsScope(
      details: entry,
      child: Builder(
        builder: (BuildContext context) => widget.itemBuilder(context, entry),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final TreeEntry<T> entry = entryAt(index);

    return _TreeEntry<T>(
      key: _SaltedKey(entry.node.id),
      entry: entry,
      itemBuilder: _wrapWithDetails,
      transitionBuilder: widget.transitionBuilder,
      onAnimationComplete: _onAnimationComplete,
      maxNodesToShow: widget.maxNodesToShowWhenAnimating,
      curve: widget.animationCurve,
      duration: widget.animationDuration,
      shouldAnimate: _animatingNodes.contains(entry.node.id),
    );
  }
}

class _SaltedKey<T extends State<StatefulWidget>> extends GlobalObjectKey<T> {
  const _SaltedKey(super.value);
}

class _TreeEntry<T extends TreeNode<T>> extends StatefulWidget {
  const _TreeEntry({
    super.key,
    required this.entry,
    required this.itemBuilder,
    required this.transitionBuilder,
    required this.onAnimationComplete,
    required this.maxNodesToShow,
    required this.curve,
    required this.duration,
    required this.shouldAnimate,
  });

  final TreeEntry<T> entry;
  final TreeViewItemBuilder<T> itemBuilder;

  final TreeViewTransitionBuilder transitionBuilder;
  final ValueSetter<T> onAnimationComplete;
  final int maxNodesToShow;
  final Curve curve;
  final Duration duration;
  final bool shouldAnimate;

  @override
  State<_TreeEntry<T>> createState() => _TreeEntryState<T>();
}

class _TreeEntryState<T extends TreeNode<T>> extends State<_TreeEntry<T>>
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
    // Sometimes when [isExpanded] changes and [entry.shouldAnimate] is set to
    // `false`, the animation value is not reset, then latter when a subsequent
    // animation starts, the controller is already completed and no animation
    // is played at all.
    final double? from = animationController.value == 1.0 ? 0.0 : null;
    animationController.forward(from: from).whenComplete(onAnimationComplete);
  }

  void collapse() {
    // Sometimes when [isExpanded] changes and [entry.shouldAnimate] is set to
    // `false`, the animation value is not reset, then latter when a subsequent
    // animation starts, the controller is already completed and no animation
    // is played at all.
    final double? from = animationController.value == 0.0 ? 1.0 : null;
    animationController.reverse(from: from).whenComplete(onAnimationComplete);
  }

  @override
  void initState() {
    super.initState();
    isExpanded = node.isExpanded;

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

    if (isExpanded != node.isExpanded) {
      isExpanded = node.isExpanded;

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
    final Widget tile = widget.itemBuilder(context, entry);

    if (widget.shouldAnimate || animationController.isAnimating) {
      final Widget subtree = _Subtree(
        virtualRoot: entry,
        maxNodesToShow: widget.maxNodesToShow,
        itemBuilder: widget.itemBuilder,
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

class _Subtree<T extends TreeNode<T>> extends StatefulWidget {
  const _Subtree({
    super.key,
    required this.virtualRoot,
    required this.maxNodesToShow,
    required this.itemBuilder,
  });

  final TreeEntry<T> virtualRoot;
  final int maxNodesToShow;
  final TreeViewItemBuilder<T> itemBuilder;

  @override
  State<_Subtree<T>> createState() => _SubtreeState<T>();
}

class _SubtreeState<T extends TreeNode<T>> extends State<_Subtree<T>> {
  TreeEntry<T> get virtualRoot => widget.virtualRoot;

  late List<TreeEntry<T>> virtualEntries;
  int nodeCount = 0;

  @override
  void initState() {
    super.initState();
    final List<TreeEntry<T>> flatTree = virtualRoot.node.children.flatten(
      rootLevel: virtualRoot.level + 1,
      onTraverse: (TreeEntry<T> entry) {
        // Apply the unreachable ancestor lines to make sure this subtree
        // doesn't appear floating "contextless" in the line hierarchy.
        entry.addVerticalLinesAtLevels(
          virtualRoot.ancestorLevelsWithVerticalLines,
        );
      },
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
            widget.itemBuilder(context, virtualEntry),
        ],
      ),
    );
  }
}
