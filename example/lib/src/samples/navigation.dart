import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../example_node.dart' show ExampleNode, ExampleTree;
import '../pages.dart' show PageInfo;

class NavigableTreeView extends StatefulWidget with PageInfo {
  const NavigableTreeView({super.key});

  @override
  String get title => 'Navigable TreeView';

  @override
  String? get description {
    return 'Use the keyboard arrow keys to navigate around:'
        '\n↑    highlight previous node'
        '\n↓    highlight next node'
        '\n→    expand or highlight next'
        '\n←    collapse or highlight parent';
  }

  @override
  State<NavigableTreeView> createState() => _NavigableTreeViewState();
}

class _NavigableTreeViewState extends State<NavigableTreeView> {
  final GlobalKey<TreeNavigationState<ExampleNode>> navKey = GlobalKey();

  late final TreeController<ExampleNode> treeController;

  ExampleNode? highlightedNode;

  @override
  void initState() {
    super.initState();

    treeController = TreeController<ExampleNode>(
      tree: ExampleTree.createSampleTree(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // highlight the first root as soon as the view renders so that the
      // navigation focus is ready to receive keyboard input.
      navKey.currentState?.highlight(treeController.tree.roots.first);
    });
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap your [SliverTree] or [TreeView] in a [TreeNavigation] to enable
    // keyboard arrow keys navigation.
    return TreeNavigation<ExampleNode>(
      key: navKey,
      controller: treeController,
      // Provide the current highlight, if any, will serve as an anchor for
      // directional highlight movements.
      currentHighlight: highlightedNode,
      canHighlight: (ExampleNode node) {
        // You can decide if a node is allowed to be highlighted.
        //
        // If this callback is not provided, all nodes are allowed to be
        // highlighted.
        return true;
      },
      onHighlightChanged: (ExampleNode? node) {
        // The [TreeNavigation] already calls [setState] internally, so we
        // only need to update our variable to keep them synced.
        highlightedNode = node;
      },
      // Provide the following method if additional work is needed when
      // indireclty expanding a node.
      expandCallback: null,
      // Provide the following method if additional work is needed when
      // indireclty collapsing a node.
      collapseCallback: null,
      // If wanted, provide any additional actions.
      //
      // Providing a [DirectionalFocusIntent] will override the default behavior
      // of [TreeNavigationState.directionalHighlight].
      actions: const <Type, Action<Intent>>{},
      child: TreeView<ExampleNode>(
        controller: treeController,
        itemBuilder: (BuildContext context, TreeEntry<ExampleNode> entry) {
          return NavigableTreeItem(
            entry: entry,
            onToggle: () => treeController.toggleExpansion(entry.node),
          );
        },
      ),
    );
  }
}

class NavigableTreeItem extends StatefulWidget {
  const NavigableTreeItem({
    super.key,
    required this.entry,
    required this.onToggle,
  });

  final TreeEntry<ExampleNode> entry;
  final VoidCallback onToggle;

  @override
  State<NavigableTreeItem> createState() => _NavigableTreeItemState();
}

class _NavigableTreeItemState extends State<NavigableTreeItem> {
  ExampleNode get node => widget.entry.node;

  late final FocusNode focusNode;

  late TreeNavigationState<ExampleNode> treeNavigation;
  bool isHighlighted = false;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAutoScroller();

    // [TreeNavigation.of] adds a dependency on its internal [InheritedWidget],
    // so this widget will rebuild when the [TreeNavigationState.currentHighlight]
    // changes.
    treeNavigation = TreeNavigation.of<ExampleNode>(context)!;
    isHighlighted = treeNavigation.currentHighlight == node;

    if (isHighlighted && !focusNode.hasFocus) {
      focusNode.requestFocus();
      _maybeAutoScroll();
    }
  }

  void onFocusChange(bool gotFocus) {
    if (gotFocus) return;

    // Avoid losing focus if highlighted
    if (isHighlighted) {
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    autoScroller?.stopAutoScroll();
    autoScroller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeItem<ExampleNode>(
      treeEntry: widget.entry,
      focusNode: focusNode,
      focusColor: Colors.transparent,
      onFocusChange: onFocusChange,
      onTap: () {
        treeNavigation.highlight(node);

        if (node.hasChildren) {
          widget.onToggle();
        }
      },
      onLongPress: () {
        if (isHighlighted) {
          treeNavigation.clearHighlight();
        } else {
          treeNavigation.highlight(node);
        }
      },
      // add a background color and a border if `isHighlighted` is set to true
      child: HighlightDecoration(
        isHighlighted: isHighlighted,
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              if (node.children.isEmpty)
                const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.article_outlined),
                )
              else
                ExpandIcon(
                  isExpanded: node.isExpanded,
                  onPressed: (_) => widget.onToggle(),
                ),
              Expanded(
                child: Text(node.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rudimentary auto scrolling setup

  VerticalEdgeDraggingAutoScroller? autoScroller;

  void _updateAutoScroller() {
    final ScrollableState scrollable = Scrollable.of(context)!;

    if (autoScroller?.scrollable != scrollable) {
      autoScroller?.stopAutoScroll();
      autoScroller = VerticalEdgeDraggingAutoScroller(
        scrollable: scrollable,
        onScrollViewScrolled: () => autoScroller?.stopAutoScroll(),
      );
    }
  }

  void _maybeAutoScroll() {
    if (autoScroller == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = context.findRenderObject()! as RenderBox;
      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
      autoScroller!.startAutoScrollIfNecessary(rect);
    });
  }
}

class HighlightDecoration extends StatelessWidget {
  const HighlightDecoration({
    super.key,
    required this.child,
    required this.isHighlighted,
  });

  final Widget child;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    if (isHighlighted) {
      final ThemeData theme = Theme.of(context);
      final ColorScheme colorScheme = theme.colorScheme;

      return DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          border: Border.all(
            color: colorScheme.secondary,
            width: 2,
          ),
        ),
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
          child: child,
        ),
      );
    }

    return child;
  }
}
