import 'package:flutter/material.dart';

import '../foundation.dart';

/// A simple widget that can be used along with a [TreeContoller] to keep track
/// of a "highlighted" node.
///
/// The most common usecase for this widget is to map keyboard shortcuts to
/// navigate around a tree view. See [TreeNavigationState.directionalHighlight].
///
/// This api can be paired with flutter's focus api to correctly focus a tree
/// item when its internal node is highlighted. Example:
///
/// ```dart
/// final T node = ...;
/// final FocusNode focusNode = ...;
///
/// final T? currentHighlight = TreeNavigation.of<T>(context)?.currentHighlight;
/// final bool isHighlighted = currentHighlight?.id == node.id;
///
/// if (isHighlighted && !focusNode.hasFocus) {
///   focusNode.requestFocus();
/// }
/// ```
class TreeNavigation<T extends TreeNode<T>> extends StatefulWidget {
  /// Creates a [TreeNavigation].
  const TreeNavigation({
    super.key,
    required this.child,
    required this.controller,
    this.currentHighlight,
    this.canHighlight,
    this.onHighlightChanged,
    this.expandCallback,
    this.collapseCallback,
    this.actions,
    this.onFocusChange,
    this.autofocus = false,
    this.focusNode,
    this.canRequestFocus = true,
  });

  /// The widget below this widget in the widget tree.
  ///
  /// Typically a [TreeView] or a [CustomScrollView] with a [SliverTree] sliver.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The tree controller that will be used to move the highlight around and
  /// expand/collapse the highlighted node if needed.
  final TreeController<T> controller;

  /// The tree node that is currently highlighted by this [TreeNavigation], if
  /// any.
  ///
  /// This can be used along with the methods of [TreeNavigationState] to update
  /// the tree node that is currently highlighted.
  final T? currentHighlight;

  /// A value mapper to decide if a node can be highlighted or not.
  ///
  /// If not provided, all nodes are allowed to be highlighted.
  final Mapper<T, bool>? canHighlight;

  /// Optional callback that is called whenever the current highlight is updated
  /// by internal [TreeNavigationState] methods.
  final ValueChanged<T?>? onHighlightChanged;

  /// The callback that will be used when a directional highlight is requested
  /// with left/right directions.
  ///
  /// Called when:
  ///  - [TraversalDirection] is `right` and [TextDirection] is `left-to-right`.
  ///  - [TraversalDirection] is `left` and [TextDirection] is `right-to-left`.
  ///
  /// If not provided, [TreeController.expand] will be used instead.
  final ValueChanged<T>? expandCallback;

  /// The callback that will be used when a directional highlight is requested
  /// with left/right directions.
  ///
  /// Called when:
  ///  - [TraversalDirection] is `left` and [TextDirection] is `left-to-right`.
  ///  - [TraversalDirection] is `right` and [TextDirection] is `right-to-left`.
  ///
  /// If not provided, [TreeController.collapse] will be used instead.
  final ValueChanged<T>? collapseCallback;

  /// {@macro flutter.widgets.actions.actions}
  final Map<Type, Action<Intent>>? actions;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.autofocus}
  final bool autofocus;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter.widgets.Focus.canRequestFocus}
  final bool canRequestFocus;

  /// The [TreeNavigationState] from the closest instance of this class that
  /// encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// TreeNavigationState<T>? navigationState = TreeNavigation.of<T>(context);
  /// ```
  static TreeNavigationState<T>? of<T extends TreeNode<T>>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<_TreeNavigationScope<T>>()
        ?.state;
  }

  @override
  State<TreeNavigation<T>> createState() => TreeNavigationState<T>();
}

/// The state of a [TreeNavigation].
///
/// Can be used to dynamically update the currently highlighted tree node.
class TreeNavigationState<T extends TreeNode<T>>
    extends State<TreeNavigation<T>> {
  late Map<Type, Action<Intent>> _actions;
  TreeController<T> get _controller => widget.controller;

  bool _isRightToLeft = false;

  FocusNode? _focusNode;
  FocusNode get _effectiveFocusNode {
    return widget.focusNode ?? (_focusNode ??= FocusNode());
  }

  TreeEntry<T>? _findTreeEntry(T? node) {
    return node == null ? null : _controller.getCurrentEntryOfNode(node);
  }

  bool _canHighlight(T? node) {
    return node == null || (widget.canHighlight?.call(node) ?? true);
  }

  void _myabeHighlightFirstVisibleNode() {
    if (_controller.flattenedTree.isEmpty) return;
    highlight(_controller.flattenedTree.first.node);
  }

  /// Updates [currentHighlight] to `null`.
  void clearHighlight() {
    if (_currentHighlight == null) return;

    setState(() {
      _currentHighlight = null;
    });

    widget.onHighlightChanged?.call(null);
  }

  /// Updates [currentHighlight] to the given [node].
  void highlight(T? node) {
    if (_currentHighlight?.id == node?.id || !_canHighlight(node)) return;

    setState(() {
      _currentHighlight = node;
    });

    widget.onHighlightChanged?.call(currentHighlight);
  }

  /// The tree node that is currently highlighted, if any.
  T? get currentHighlight => _currentHighlight;
  T? _currentHighlight;

  /// Moves the current highlight to the previous node.
  ///
  /// If the [currentHighlight] is the first entry of [flattenedTree], this does
  /// nothing.
  void previousHighlight() {
    final TreeEntry<T>? anchor = _findTreeEntry(_currentHighlight);
    highlight(anchor?.previousEntry?.node);
  }

  /// Moves the current highlight to the next node.
  ///
  /// If the [currentHighlight] is the last entry of [flattenedTree], this does
  /// nothing.
  void nextHighlight() {
    final TreeEntry<T>? anchor = _findTreeEntry(_currentHighlight);
    highlight(anchor?.nextEntry?.node);
  }

  /// Moves the [currentHighlight] on the given [TraversalDirection].
  ///
  /// If [currentHighlight] is `null`, nothing happens.
  ///
  /// When the direction is either [TraversalDirection.left] or
  /// [TraversalDirection.right], [Directionality.maybeOf] will be used to apply
  /// the correct traversal behavior, if `null` it defaults to left-to-right.
  ///
  /// Highlight behavior by direction:
  ///
  /// - [TraversalDirection.up]: Move highlight to the previous node.
  /// - [TraversalDirection.down]: Move highlight to the next node.
  ///
  /// > Depending on [Directionality.maybeOf] ([TextDirection.ltr] as default),
  /// > the following directions will have their behaviors swapped:
  ///
  /// - [TraversalDirection.left]:
  ///   - [TextDirection.ltr]: Collapse or move highlight to parent.
  ///   - [TextDirection.rtl]: Expand or move highlight to the next node.
  ///
  /// - [TraversalDirection.right].
  ///   - [TextDirection.ltr]: Expand or move highlight to the next node.
  ///   - [TextDirection.rtl]: Collapse or move highlight to parent.
  ///
  /// In case the move ever fails to find a target, [currentHighlight] keeps the
  /// highlight.
  void directionalHighlight(TraversalDirection direction) {
    final TreeEntry<T>? anchor = _findTreeEntry(_currentHighlight);

    if (anchor == null) {
      _myabeHighlightFirstVisibleNode();
      return;
    }

    TreeEntry<T>? target;

    switch (direction) {
      case TraversalDirection.up:
        target = anchor.previousEntry;
        break;

      case TraversalDirection.right:
        if (_isRightToLeft) {
          target = _moveToParentOrCollapse(anchor);
        } else {
          target = _moveNextOrExpand(anchor);
        }
        break;

      case TraversalDirection.down:
        target = anchor.nextEntry;
        break;

      case TraversalDirection.left:
        if (_isRightToLeft) {
          target = _moveNextOrExpand(anchor);
        } else {
          target = _moveToParentOrCollapse(anchor);
        }
        break;
    }

    highlight(target?.node ?? anchor.node);
  }

  ValueChanged<T> get _collapseCallback {
    return widget.collapseCallback ?? _controller.collapse;
  }

  ValueChanged<T> get _expandCallback {
    return widget.expandCallback ?? _controller.expand;
  }

  TreeEntry<T>? _moveToParentOrCollapse(TreeEntry<T> anchor) {
    if (!anchor.node.isExpanded) {
      return anchor.parent;
    }
    _collapseCallback(anchor.node);
    return null;
  }

  TreeEntry<T>? _moveNextOrExpand(TreeEntry<T> anchor) {
    if (anchor.node.isExpanded) {
      return anchor.nextEntry;
    }
    _expandCallback(anchor.node);
    return null;
  }

  late final Action<Intent> _action = CallbackAction<DirectionalFocusIntent>(
    onInvoke: (DirectionalFocusIntent intent) {
      return directionalHighlight(intent.direction);
    },
  );

  void _updateActions() {
    _actions = <Type, Action<Intent>>{
      DirectionalFocusIntent: _action,
      ...?widget.actions,
    };
  }

  @override
  void initState() {
    super.initState();
    _updateActions();
    _currentHighlight = widget.currentHighlight;
  }

  @override
  void didUpdateWidget(covariant TreeNavigation<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentHighlight?.id != currentHighlight?.id) {
      _currentHighlight = widget.currentHighlight;
    }

    if (oldWidget.actions != widget.actions) {
      _updateActions();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isRightToLeft = Directionality.maybeOf(context) == TextDirection.rtl;
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _focusNode = null;
    _currentHighlight = null;
    _actions = const {};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.canRequestFocus ? _effectiveFocusNode.requestFocus : null,
      child: Actions(
        actions: _actions,
        child: Focus(
          focusNode: _effectiveFocusNode,
          autofocus: widget.autofocus,
          onFocusChange: widget.onFocusChange,
          canRequestFocus: widget.canRequestFocus,
          child: _TreeNavigationScope<T>(
            state: this,
            currentHighlight: currentHighlight,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _TreeNavigationScope<T extends TreeNode<T>> extends InheritedWidget {
  const _TreeNavigationScope({
    super.key,
    required this.state,
    required this.currentHighlight,
    required super.child,
  });

  final TreeNavigationState<T> state;
  final T? currentHighlight;

  @override
  bool updateShouldNotify(_TreeNavigationScope<T> oldWidget) {
    return oldWidget.currentHighlight != currentHighlight;
  }
}
