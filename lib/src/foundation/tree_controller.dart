import 'dart:collection' show HashMap, UnmodifiableListView;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'tree_node.dart';

/// A simple controller responsible for managing the state of a [SliverTree].
///
/// There are several ways to disable animations. The easiest way is to provide
/// a [Duration.zero] to [TreeController.animationDuration] which will disable
/// all animations; or individually for each expanding/collapsing method through
/// their `duration` optional parameter which, when not provided, defaults to
/// [TreeController.animationDuration].
/// Animations can also be disabled by updating the expansion state of nodes
/// directly and then calling [TreeController.rebuild].
/// > When animating collapse commands, the changes to [TreeNode.isExpanded] are
/// > only applied after the animation completes because we have to wait for the
/// > nodes to be animated before being removed from [flattenedTree], otherwise
/// > the nodes would just vanish instantly.
/// > When animating expand operations, the changes take effect immediately.
class TreeController<T extends TreeNode<T>> with ChangeNotifier {
  /// Creates a [TreeController].
  ///
  /// To disable animations, provide a duration of [Duration.zero] to
  /// [animationDuration].
  ///
  /// [startingLevel] the level to use for root nodes when flattening the tree.
  /// Must be greater or equal to `0`. To paint lines for the root nodes, use
  /// a starting level of `1` or higher. The higher the starting level, more
  /// indent the flattening algorithm will apply to the total indentation of the
  /// nodes.
  ///
  /// [showRoot] controls whether to display [root] or [root.children] as the
  /// root(s) of the tree. Set to `true` if [root] should be visible.
  TreeController({
    required T root,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.linear,
    bool showRoot = false,
    int startingLevel = defaultTreeRootLevel,
  })  : _root = root,
        _showRoot = showRoot,
        assert(startingLevel >= 0),
        _startingLevel = startingLevel;

  @override
  void dispose() {
    _flatTree = UnmodifiableListView(const []);
    _entryByIdCache.clear();
    _commands.clear();
    super.dispose();
  }

  /// The [TreeNode] that is used as a starting point to build the flat
  /// representation of a tree.
  T get root => _root;
  T _root;
  set root(T newRoot) {
    if (newRoot == _root) return;
    _root = newRoot;
    rebuild();
  }

  /// Whether [root] should be the only root of [flattenedTree] or if each node
  /// of [root.children] should become a root.
  ///
  /// If set to `false` (default), every child of [root] will become a root and
  /// [root] itself will be hidden.
  bool get showRoot => _showRoot;
  bool _showRoot;
  set showRoot(bool value) {
    if (_showRoot == value) return;
    _showRoot = value;
    rebuild();
  }

  /// Used when flattening the tree to determine the level of the root nodes.
  ///
  /// Must be a positive integer.
  ///
  /// Can be used to increase the indentation of nodes, if set to `1` root nodes
  /// will have 1 level of indentation and lines will be painted at root level
  /// (if line painting is enabled), if set to `0` ([defaultTreeRootLevel])
  /// root nodes won`t have any indentation and no lines will be painted for
  /// them.
  ///
  /// The higher the starting level, more [IndentGuide.indent] is going to be
  /// added to the indentation of a node.
  ///
  /// Defaults to [defaultTreeRootLevel], usual values are `0` or `1`.
  int get startingLevel => _startingLevel;
  int _startingLevel;
  set startingLevel(int level) {
    if (level == _startingLevel) return;
    assert(_startingLevel >= 0);
    _startingLevel = level;
    rebuild();
  }

  /// The default duration to use when animating a [AnimatableTreeCommand].
  ///
  /// Used as a fallback value when not providing a duration to a expansion
  /// updating method.
  ///
  /// To disable all animations, set [animationDuration] to [Duration.zero].
  ///
  /// Defaults to `Duration(milliseconds: 300)`.
  Duration animationDuration;

  /// The default curve to use when animating a [AnimatableTreeCommand].
  ///
  /// Used as a fallback value when not providing a curve to a expansion
  /// updating method.
  ///
  /// Defaults to `Curves.linear`.
  Curve animationCurve;

  /// The most recent tree flattened from [root].
  UnmodifiableListView<TreeEntry<T>> get flattenedTree => _flatTree;
  UnmodifiableListView<TreeEntry<T>> _flatTree = UnmodifiableListView(const []);

  /// Returns the [TreeEntry] bound to [node] in the current flattened tree.
  ///
  /// If this returns `null`, [node] is currently hidden (an ancestor is
  /// collapsed) or it doesn't belong in this tree.
  ///
  /// If holding on to [TreeEntry] instances, make sure to add a listener on
  /// this controller to update the entry every time the tree is flattened. When
  /// the tree is flattened, all [TreeEntry] instances are replaced.
  TreeEntry<T>? getCurrentEntryOfNode(T node) => _entryByIdCache[node.id];
  final HashMap<Object, TreeEntry<T>> _entryByIdCache = HashMap();

  /// Returns the [TreeEntry] at the given [index] of the current [flattenedTree].
  TreeEntry<T> entryAt(int index) => flattenedTree[index];

  void _updateTree() {
    _entryByIdCache.clear();

    final List<TreeEntry<T>> flatTree = buildFlatTree<T>(
      roots: showRoot ? <T>[root] : root.children,
      startingLevel: startingLevel,
      descendCondition: _descendCondition,
      onTraverse: (TreeEntry<T> entry) {
        _entryByIdCache[entry.node.id] = entry;
      },
    );

    _flatTree = UnmodifiableListView<TreeEntry<T>>(flatTree);
  }

  final HashMap<Object, AnimatableTreeCommand<T>> _commands = HashMap();

  /// Simplify tree flattening by not calling [Map.constainsKey] if there are no
  /// commands to animate.
  Mapper<TreeEntry<T>, bool>? get _descendCondition => _commands.isEmpty
      ? null
      : (TreeEntry<T> entry) {
          if (_commands.containsKey(entry.node.id)) {
            // The descendants of a node that is animating should not be
            // included in the flattened tree since those nodes are going to
            // be rendered in a single tile.
            return false;
          }
          return entry.node.includeChildrenWhenFlattening;
        };

  void _executeCommand({
    required T node,
    required AnimatableTreeCommand<T> command,
  }) {
    // Make sure to run the expanding commands before the next flattening even
    // if animations are disabled.
    command.onStart();

    if (command.executeImmediately) {
      // If not animating, `onEnd` is called right away so nodes that need to be
      // collapsed do so before the next flattening.
      command.onEnd();
    } else {
      // Add the command to animate the next time the flattened tree is built.
      _commands[node.id] = command;
    }
  }

  /// Returns the animatable command (if any) that is bound to [node] in the
  /// current flattened tree.
  ///
  /// Animatable commands are used to animate the expanding/collapsing branches.
  AnimatableTreeCommand<T>? getAnimatableCommand(T node) => _commands[node.id];

  /// Used by [SliverTree] to notify the controller that [node] is done
  /// animating so the related command can be completed.
  void onAnimatableCommandComplete(T node) {
    final AnimatableTreeCommand<T>? command = _commands.remove(node.id);

    if (command == null) return;

    command.onEnd();
    rebuild();
  }

  /// Rebuilds the current tree.
  ///
  /// This method will call [setState] building the new flat tree.
  ///
  /// Call this method whenever the tree nodes are updated (i.e child added or
  /// removed, node reordered, etc...). Most methods like `expand`, `collapse`
  /// and its variations already call [rebuild].
  ///
  /// [rebuild] can also be used to update the tree without animating.
  ///
  /// When updating the expansion state of a node from outside of the methods
  /// of [TreeController], [rebuild] must be called to update the tree.
  ///
  /// Example:
  /// ```dart
  /// class Node extends TreeNode<Node> {
  ///   // ...
  /// }
  ///
  /// final TreeController<Node> treeController = SliverTree.of<Node>(context).controller;
  ///
  /// // DON'T use rebuild when calling an expansion method of [TreeController]:
  /// void expand(Node node) {
  ///   treeController.expand(node);
  ///   // treeController.rebuild(); // No need to call rebuild here.
  /// }
  ///
  /// // DO use rebuild when the expansion state is changed by outside sources:
  /// void expand(Node node) {
  ///   node.isExpanded = !node.isExpanded;
  ///   treeController.rebuild(); // Call rebuild to update the tree
  /// }
  ///
  /// // DO use rebuild when nodes are added/removed/reordered:
  /// void addChild(Node parent, Node child) {
  ///   parent.children.add(child)
  ///   treeController.rebuild();
  /// }
  ///
  /// /// Consider doing bulk updating before calling rebuild:
  /// void addChildren(Node parent, List<Node> children) {
  ///   for (final Node child in children) {
  ///     parent.children.add(child);
  ///     // DON'T rebuild after each child insertion
  ///     // treeController.rebuild();
  ///   }
  ///   // DO rebuild after all nodes are processed
  ///   treeController.rebuild();
  /// }
  /// ```
  void rebuild() {
    _updateTree();
    notifyListeners();
  }

  /// Updates [node]'s expansion state to the opposite state.
  ///
  /// {@template flutter_fancy_tree_view.tree_controller.expand_animation}
  /// If [duration] is `null`, defaults to [TreeController.animationDuration].
  /// To disable animations for this method only, provide a duration of
  /// [Duration.zero].
  ///
  /// If [curve] is `null`, defaults to [TreeController.animationCurve].
  /// {@endtemplate}
  ///
  /// When collapsing,
  /// {@template flutter_fancy_tree_view.tree_controller.collapse_animation}
  /// The updates to [TreeNode.isExpanded] are delayed to when the animation
  /// finishes, since if the nodes are collapsed before animating, they would
  /// not be part of [flattenedTree], vanishing instead of animating out.
  /// {@endtemplate}
  void toggleExpansion(T node, {Duration? duration, Curve? curve}) {
    node.isExpanded
        ? collapse(node, duration: duration, curve: curve)
        : expand(node, duration: duration, curve: curve);
  }

  /// Updates [node]'s expansion state to `true` and rebuilds the tree.
  ///
  /// No checks are done to [node]. So, this will execute even if it is already
  /// expanded.
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.expand_animation}
  void expand(T node, {Duration? duration, Curve? curve}) {
    _executeCommand(
      node: node,
      command: AnimatableTreeCommand<T>.expand(
        node: node,
        duration: duration ?? animationDuration,
        curve: curve ?? animationCurve,
      ),
    );
    rebuild();
  }

  /// Traverses [node]'s branch updating all descendants' expansion state to
  /// `true` and rebuilds the tree.
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.expand_animation}
  void expandCascading(T node, {Duration? duration, Curve? curve}) {
    _executeCommand(
      node: node,
      command: AnimatableTreeCommand<T>.expandCascading(
        node: node,
        duration: duration ?? animationDuration,
        curve: curve ?? animationCurve,
      ),
    );
    rebuild();
  }

  /// Updates the expansion state of all nodes to `true` and rebuilds the tree.
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.expand_animation}
  void expandAll({Duration? duration, Curve? curve}) {
    _executeCommand(
      node: root,
      command: AnimatableTreeCommand<T>.expandCascading(
        node: root,
        duration: duration ?? animationDuration,
        curve: curve ?? animationCurve,
      ),
    );

    rebuild();
  }

  /// Updates [node]'s expansion state to `false` and rebuilds the tree.
  ///
  /// No checks are done to [node]. So, this will execute even if it is already
  /// collapsed.
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.expand_animation}
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.collapse_animation}
  void collapse(T node, {Duration? duration, Curve? curve}) {
    _executeCommand(
      node: node,
      command: AnimatableTreeCommand<T>.collapse(
        node: node,
        duration: duration ?? animationDuration,
        curve: curve ?? animationCurve,
      ),
    );
    rebuild();
  }

  /// Traverses [node]'s branch updating all descendants' expansion state to
  /// `false` and rebuilds the tree.
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.expand_animation}
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.collapse_animation}
  void collapseCascading(T node, {Duration? duration, Curve? curve}) {
    _executeCommand(
      node: node,
      command: AnimatableTreeCommand<T>.collapseCascading(
        node: node,
        duration: duration ?? animationDuration,
        curve: curve ?? animationCurve,
      ),
    );
    rebuild();
  }

  /// Updates the expansion state of all nodes to `false` and rebuilds the tree.
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.expand_animation}
  ///
  /// {@macro flutter_fancy_tree_view.tree_controller.collapse_animation}
  void collapseAll({Duration? duration, Curve? curve}) {
    _executeCommand(
      node: root,
      command: AnimatableTreeCommand<T>.collapseCascading(
        node: root,
        duration: duration ?? animationDuration,
        curve: curve ?? animationCurve,
      ),
    );

    rebuild();
  }
}

/// Convenient extension methods to reduce code repetition.
extension _TreeExtension<T extends TreeNode<T>> on T {
  bool get isLeaf => children.isEmpty;

  void expandCascading() {
    isExpanded = true;
    for (final T child in children) {
      child.expandCascading();
    }
  }

  void collapseCascading() {
    isExpanded = false;
    for (final T child in children) {
      child.expandCascading();
    }
  }
}

/// An interface used by [TreeController] to animate expansion state changes.
///
/// Expanding commands are executed **before** animating so revealing nodes are
/// present on the new flattened tree.
///
/// Collapsing commands are executed **after** animating so concealing nodes are
/// present on the flattened tree until the animation is complete.
abstract class AnimatableTreeCommand<T extends TreeNode<T>> {
  /// Abstract constant constructor.
  const AnimatableTreeCommand({
    required this.duration,
    required this.curve,
  });

  /// A tree command that expands a single tree node.
  const factory AnimatableTreeCommand.expand({
    required T node,
    required Duration duration,
    required Curve curve,
  }) = _Expand<T>;

  /// A tree command that recursively expands [node] and every descendant.
  const factory AnimatableTreeCommand.expandCascading({
    required T node,
    required Duration duration,
    required Curve curve,
  }) = _ExpandCascading<T>;

  /// A tree command that collapses a single tree node.
  const factory AnimatableTreeCommand.collapse({
    required T node,
    required Duration duration,
    required Curve curve,
  }) = _Collapse<T>;

  /// A tree command that recursively collapses [node] and every descendant.
  const factory AnimatableTreeCommand.collapseCascading({
    required T node,
    required Duration duration,
    required Curve curve,
  }) = _CollapseCascading<T>;

  /// The duration to use when animating the execution of this command.
  final Duration duration;

  /// The curve to use when animating the execution of this command.
  final Curve curve;

  /// Whether this command should be executed right away without animating.
  bool get executeImmediately => duration == Duration.zero;

  /// Optional overridable method called when this command is added to the set
  /// of commands that will take effect on the next time the tree is flattened.
  ///
  /// > On expanding commands, we need to update node's expansion state _before_
  /// > animating, otherwise the revealed descendants wouldn't be part of the
  /// > new flattened tree, therefore not animating at all.
  ///
  /// > On collapsing commands, this method does nothing.
  ///
  /// Calling this method directly could lead to inconsitent tree state.
  void onStart() {}

  /// Optional overridable method called when the expand/collapse animation
  /// completes and this command is being destroyed.
  ///
  /// > On collapsing commands, we need to update node's expansion state _after_
  /// > animating, otherwise the concealed descendants wouldn't be part of the
  /// > flattened tree, therefore not animating at all.
  ///
  /// > On expanding commands, this method does nothing.
  ///
  /// Calling this method directly could lead to inconsitent tree state.
  void onEnd() {}

  /// Subclasses should override this method to start the animation on the given
  /// [AnimationController].
  ///
  /// The expanding commands uses `controller.forward(from: 0.0)`.
  /// The collapsing commands uses `controller.reverse(from: 1.0)`.
  ///
  /// This method is called by the [SliverTree] when it is ready for the
  /// animation of this command to begin.
  TickerFuture animate(AnimationController controller);
}

class _Expand<T extends TreeNode<T>> extends AnimatableTreeCommand<T> {
  const _Expand({
    required this.node,
    required super.duration,
    required super.curve,
  });

  final T node;

  @override
  bool get executeImmediately => node.isLeaf || duration == Duration.zero;

  @override
  void onStart() => node.isExpanded = true;

  @override
  TickerFuture animate(AnimationController controller) {
    return controller.forward(from: 0.0);
  }
}

class _ExpandCascading<T extends TreeNode<T>> extends _Expand<T> {
  const _ExpandCascading({
    required super.node,
    required super.duration,
    required super.curve,
  });

  @override
  void onStart() => node.expandCascading();
}

class _Collapse<T extends TreeNode<T>> extends AnimatableTreeCommand<T> {
  const _Collapse({
    required this.node,
    required super.duration,
    required super.curve,
  });

  final T node;

  @override
  bool get executeImmediately => node.isLeaf || duration == Duration.zero;

  @override
  void onEnd() => node.isExpanded = false;

  @override
  TickerFuture animate(AnimationController controller) {
    return controller.reverse(from: 1.0);
  }
}

class _CollapseCascading<T extends TreeNode<T>> extends _Collapse<T> {
  const _CollapseCascading({
    required super.node,
    required super.duration,
    required super.curve,
  });

  @override
  void onEnd() => node.collapseCascading();
}
