import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../example_node.dart';
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
  late final TreeController<ExampleNode> treeController;

  ExampleNode? currentHighlight;

  @override
  void initState() {
    super.initState();

    treeController = TreeController<ExampleNode>(
      root: ExampleNode.createSampleTree(),
    );

    // highlight the first visible node
    currentHighlight = treeController.root.children.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // request focus as soon as the view renders so that the
      // navigation focus is ready to receive keyboard input.
      currentHighlight?.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    treeController
      ..root.visitDescendants((ExampleNode descendant) => descendant.dispose())
      ..dispose();
    super.dispose();
  }

  void toggleExpansionWithoutAnimating(ExampleNode node) {
    if (!node.hasChildren) return;
    treeController.toggleExpansion(node, duration: Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    // Wrap your [SliverTree] or [TreeView] in a [TreeNavigation] to enable
    // keyboard arrow keys navigation.
    return TreeNavigation<ExampleNode>(
      controller: treeController,
      // Provide the current highlight, if any, will serve as an anchor for
      // directional highlight movements.
      currentHighlight: currentHighlight,
      canHighlight: (ExampleNode node) {
        // You can decide if a node is allowed to be highlighted.
        //
        // If this callback is not provided, all nodes are allowed to be
        // highlighted.
        return true;
      },
      onHighlightChanged: (ExampleNode? node) {
        primaryFocus?.unfocus();
        // The [TreeNavigation] already calls [setState] internally, so we
        // only need to update our variable to keep them synced.
        currentHighlight = node?..focusNode.requestFocus();
      },
      // Provide the following method(s) if additional work is needed when
      // indireclty updating the expansion state of a node.
      expandCallback: toggleExpansionWithoutAnimating,
      collapseCallback: toggleExpansionWithoutAnimating,
      actions: const <Type, Action<Intent>>{
        // If desired, provide additional actions.
        //
        // Providing a [DirectionalFocusIntent] will override the default
        // behavior of [TreeNavigationState.directionalHighlight].
      },
      child: TreeView<ExampleNode>(
        controller: treeController,
        itemBuilder: (BuildContext context, TreeEntry<ExampleNode> entry) {
          return NavigableTreeItem(
            node: entry.node,
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
    required this.node,
    required this.onToggle,
  });

  final ExampleNode node;
  final VoidCallback onToggle;

  @override
  State<NavigableTreeItem> createState() => _NavigableTreeItemState();
}

class _NavigableTreeItemState extends State<NavigableTreeItem> {
  ExampleNode get node => widget.node;

  late TreeNavigationState<ExampleNode> treeNavigation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    treeNavigation = TreeNavigation.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return TreeItem(
      focusNode: node.focusNode,
      focusColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
      onFocusChange: (bool hasFocus) {
        if (!hasFocus) return;

        final RenderObject? renderObject = context.findRenderObject();
        RenderAbstractViewport.of(renderObject)?.showOnScreen(
          descendant: renderObject,
        );
      },
      onTap: () {
        treeNavigation.highlight(node);

        if (node.hasChildren) {
          widget.onToggle();
        }
      },
      onLongPress: () {
        if (node.isHighlighted) {
          treeNavigation.clearHighlight();
        } else {
          treeNavigation.highlight(node);
        }
      },
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
    );
  }
}
