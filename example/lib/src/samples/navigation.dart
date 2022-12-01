import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../example_node.dart' show createSampleTree;
import '../pages.dart' show PageInfo;

class NavigableNode extends TreeNode<NavigableNode> {
  NavigableNode({
    required this.label,
    List<NavigableNode>? children,
  }) : children = children ?? <NavigableNode>[];

  final String label;

  @override
  final List<NavigableNode> children;

  FocusNode get focusNode => _focusNode ??= FocusNode();
  FocusNode? _focusNode;

  void dispose() {
    _focusNode?.dispose();
    _focusNode = null;
  }
}

class NavigableTreeView extends StatefulWidget with PageInfo {
  const NavigableTreeView({super.key});

  @override
  String get title => 'Navigable TreeView';

  @override
  String? get description {
    return 'Use the keyboard arrow keys to navigate around:'
        '\n↑    focus previous node'
        '\n↓    focus next node'
        '\n→    expand or focus next'
        '\n←    collapse or focus parent';
  }

  @override
  State<NavigableTreeView> createState() => _NavigableTreeViewState();
}

class _NavigableTreeViewState extends State<NavigableTreeView> {
  late final NavigableNode root;

  @override
  void initState() {
    super.initState();
    root = createSampleTree(NavigableNode.new);
  }

  @override
  void dispose() {
    root.visitDescendants((NavigableNode descendant) => descendant.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<NavigableNode>(
      roots: root.children,
      animationDuration: Duration.zero,
      itemBuilder: (BuildContext context, TreeEntry<NavigableNode> entry) {
        return NavigableTreeItem(entry: entry);
      },
    );
  }
}

class NavigableTreeItem extends StatefulWidget {
  const NavigableTreeItem({super.key, required this.entry});

  final TreeEntry<NavigableNode> entry;

  @override
  State<NavigableTreeItem> createState() => _NavigableTreeItemState();
}

class _NavigableTreeItemState extends State<NavigableTreeItem> {
  TreeEntry<NavigableNode> get entry => widget.entry;
  NavigableNode get node => entry.node;

  FocusNode get focusNode => node.focusNode;
  late SliverTreeState<NavigableNode> treeState;
  bool isRightToLeft = false;

  KeyEventResult _handleKeyEvent(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) {
      (entry.previousEntry ?? entry).node.focusNode.requestFocus();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      (entry.nextEntry ?? entry).node.focusNode.requestFocus();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (entry.isExpanded) {
        (entry.nextEntry ?? entry).node.focusNode.requestFocus();
      } else {
        treeState.toggleExpansion(entry.node, animate: false);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (entry.isExpanded) {
        treeState.toggleExpansion(entry.node, animate: false);
      } else {
        (entry.nextEntry ?? entry).node.focusNode.requestFocus();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    treeState = SliverTree.of<NavigableNode>(context);
    isRightToLeft = Directionality.maybeOf(context) == TextDirection.rtl;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      onFocusChange: (bool hasFocus) {
        if (!hasFocus) return;
        _showOnScreen();
      },
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (KeyEvent is! RawKeyEvent) return KeyEventResult.ignored;
        return _handleKeyEvent(event.logicalKey);
      },
      child: NavigableNodeTile(
        node: node,
        isExpanded: entry.isExpanded,
      ),
    );
  }

  void _showOnScreen() {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) return;
    RenderAbstractViewport.of(renderObject)?.showOnScreen(
      descendant: renderObject,
    );
  }
}

class NavigableNodeTile extends StatelessWidget {
  const NavigableNodeTile({
    super.key,
    required this.node,
    this.isExpanded = false,
  });

  final NavigableNode node;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return TreeItem(
      onTap: () {
        node.focusNode.requestFocus();

        if (node.children.isNotEmpty) {
          SliverTree.of<NavigableNode>(context).toggleExpansion(node);
        }
      },
      onLongPress: () {
        node.focusNode.hasFocus
            ? node.focusNode.unfocus()
            : node.focusNode.requestFocus();
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
              Padding(
                padding: const EdgeInsets.all(8),
                child: isExpanded
                    ? const Icon(Icons.expand_less)
                    : const Icon(Icons.expand_more),
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
