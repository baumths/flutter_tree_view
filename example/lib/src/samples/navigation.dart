import 'package:flutter/material.dart';
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
  late final ExampleNode root;
  late final GlobalKey<TreeViewState<ExampleNode>> treeViewKey = GlobalKey();

  ExampleNode? currentHighlight;

  @override
  void initState() {
    super.initState();

    root = ExampleNode.createSampleTree();

    // highlight the first visible node
    currentHighlight = root.children.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // request focus as soon as the view renders so that the
      // navigation focus is ready to receive keyboard input.
      currentHighlight?.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    root.visitDescendants((ExampleNode descendant) => descendant.dispose());
    super.dispose();
  }

  void toggleExpansionWithoutAnimating(ExampleNode node) {
    treeViewKey.currentState!.toggleExpansion(node, animate: false);
  }

  @override
  Widget build(BuildContext context) {
    return TreeView<ExampleNode>(
      key: treeViewKey,
      roots: root.children,
      itemBuilder: (BuildContext context, TreeEntry<ExampleNode> entry) {
        return NavigableTreeItem(
          entry: entry,
          onToggle: () => treeViewKey.currentState!.toggleExpansion(entry.node),
        );
      },
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
  TreeEntry<ExampleNode> get entry => widget.entry;
  ExampleNode get node => entry.node;

  late SliverTreeState<ExampleNode> treeState;

  late final Map<Type, Action<Intent>> _acitons = {
    DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
      onInvoke: directionalFocusAction,
    ),
  };

  void directionalFocusAction(DirectionalFocusIntent intent) {
    TreeEntry<ExampleNode>? target;
    ScrollPositionAlignmentPolicy policy =
        ScrollPositionAlignmentPolicy.explicit;

    switch (intent.direction) {
      case TraversalDirection.up:
        target = entry.previousEntry;
        policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
        break;
      case TraversalDirection.right:
        policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
        if (entry.node.isExpanded) {
          target = entry.nextEntry;
        } else {
          entry.node.isExpanded = true;
          treeState.rebuild(animate: false);
        }
        break;
      case TraversalDirection.down:
        policy = ScrollPositionAlignmentPolicy.keepVisibleAtEnd;
        target = entry.nextEntry;
        break;
      case TraversalDirection.left:
        policy = ScrollPositionAlignmentPolicy.keepVisibleAtStart;
        if (entry.node.isExpanded) {
          entry.node.isExpanded = false;
          treeState.rebuild(animate: false);
        } else {
          target = entry.parent;
        }
        break;
    }

    final FocusNode focusNode = (target ?? entry).node.focusNode;
    focusNode.requestFocus();
    if (focusNode.context == null) return;
    Scrollable.ensureVisible(
      focusNode.context!,
      alignment: 1.0,
      alignmentPolicy: policy,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    treeState = SliverTree.of<ExampleNode>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: _acitons,
      child: TreeItem(
        focusNode: node.focusNode,
        focusColor: Theme.of(context).colorScheme.primary.withOpacity(.3),
        onFocusChange: (bool hasFocus) {
          if (!hasFocus) return;

          // final RenderObject? renderObject = context.findRenderObject();
          // RenderAbstractViewport.of(renderObject)?.showOnScreen(
          //   descendant: renderObject,
          // );
        },
        onTap: () {
          node.focusNode.requestFocus();

          if (node.hasChildren) {
            widget.onToggle();
          }
        },
        onLongPress: () {
          node.isHighlighted
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
}
