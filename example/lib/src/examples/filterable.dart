import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../shared.dart' show watchAnimationDurationSetting;

class Node {
  Node({
    required this.title,
    Iterable<Node>? children,
  }) : children = <Node>[...?children];

  final String title;
  final List<Node> children;
}

class FilterableTreeView extends StatefulWidget {
  const FilterableTreeView({super.key});

  @override
  State<FilterableTreeView> createState() => _FilterableTreeViewState();
}

class _FilterableTreeViewState extends State<FilterableTreeView> {
  late final TextEditingController searchBarTextEditingController;
  late final TreeController<Node> treeController;
  late final Node root = Node(title: '/');

  TreeSearchResult<Node>? filter;
  Pattern? searchPattern;

  Iterable<Node> getChildren(Node node) {
    if (filter case TreeSearchResult<Node> filter?) {
      return node.children.where(filter.hasMatch);
    }
    return node.children;
  }

  void search(String query) {
    // Needs to be reset before searching again, otherwise the tree controller
    // wouldn't reach some nodes because of the `getChildren()` impl above.
    filter = null;

    Pattern pattern;
    try {
      pattern = RegExp(query);
    } on FormatException {
      pattern = query;
    }
    searchPattern = pattern;

    filter = treeController.search((Node node) => node.title.contains(pattern));
    treeController.rebuild();

    if (mounted) {
      setState(() {});
    }
  }

  void clearSearch() {
    if (filter == null) return;

    setState(() {
      filter = null;
      searchPattern = null;
      treeController.rebuild();
      searchBarTextEditingController.clear();
    });
  }

  void onSearchQueryChanged() {
    final String query = searchBarTextEditingController.text.trim();

    if (query.isEmpty) {
      clearSearch();
      return;
    }

    search(query);
  }

  @override
  void initState() {
    super.initState();
    populateExampleTree(root);

    treeController = TreeController<Node>(
      roots: root.children,
      childrenProvider: getChildren,
    )..expandAll();

    searchBarTextEditingController = TextEditingController();
    searchBarTextEditingController.addListener(onSearchQueryChanged);
  }

  @override
  void dispose() {
    filter = null;
    searchPattern = null;
    treeController.dispose();
    searchBarTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: SearchBar(
            controller: searchBarTextEditingController,
            hintText: 'Type to Filter',
            leading: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.filter_list),
            ),
            trailing: [
              Badge(
                isLabelVisible: filter != null,
                label: Text(
                  '${filter?.totalMatchCount}/${filter?.totalNodeCount}',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: clearSearch,
              )
            ],
          ),
        ),
        Expanded(
          child: AnimatedTreeView<Node>(
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
              return TreeTile(
                entry: entry,
                match: filter?.matchOf(entry.node),
                searchPattern: searchPattern,
              );
            },
            duration: watchAnimationDurationSetting(context),
          ),
        ),
      ],
    );
  }
}

class TreeTile extends StatefulWidget {
  const TreeTile({
    super.key,
    required this.entry,
    required this.match,
    required this.searchPattern,
  });

  final TreeEntry<Node> entry;
  final TreeSearchMatch? match;
  final Pattern? searchPattern;

  @override
  State<TreeTile> createState() => _TreeTileState();
}

class _TreeTileState extends State<TreeTile> {
  late InlineSpan titleSpan;

  TextStyle? dimStyle;
  TextStyle? highlightStyle;

  bool get shouldShowBadge =>
      !widget.entry.isExpanded && (widget.match?.subtreeMatchCount ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return TreeIndentation(
      entry: widget.entry,
      child: Row(
        children: [
          ExpandIcon(
            key: GlobalObjectKey(widget.entry.node),
            isExpanded: widget.entry.isExpanded,
            onPressed: (_) => TreeViewScope.of<Node>(context)
              ..controller.toggleExpansion(widget.entry.node),
          ),
          if (shouldShowBadge)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Badge(
                label: Text('${widget.match?.subtreeMatchCount}'),
              ),
            ),
          Flexible(child: Text.rich(titleSpan)),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setupTextStyles();
    titleSpan = buildTextSpan();
  }

  @override
  void didUpdateWidget(covariant TreeTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchPattern != widget.searchPattern ||
        oldWidget.entry.node.title != widget.entry.node.title) {
      titleSpan = buildTextSpan();
    }
  }

  void setupTextStyles() {
    final TextStyle style = DefaultTextStyle.of(context).style;
    final Color highlightColor = Theme.of(context).colorScheme.primary;
    highlightStyle = style.copyWith(
      color: highlightColor,
      decorationColor: highlightColor,
      decoration: TextDecoration.underline,
    );
    dimStyle = style.copyWith(color: style.color?.withAlpha(128));
  }

  InlineSpan buildTextSpan() {
    final String title = widget.entry.node.title;

    if (widget.searchPattern == null) {
      return TextSpan(text: title);
    }

    final List<InlineSpan> spans = <InlineSpan>[];
    bool hasAnyMatches = false;

    title.splitMapJoin(
      widget.searchPattern!,
      onMatch: (Match match) {
        hasAnyMatches = true;
        spans.add(TextSpan(text: match.group(0)!, style: highlightStyle));
        return '';
      },
      onNonMatch: (String text) {
        spans.add(TextSpan(text: text));
        return '';
      },
    );

    if (hasAnyMatches) {
      return TextSpan(children: spans);
    }

    return TextSpan(text: title, style: dimStyle);
  }
}

final lorem = faker.Faker().lorem;
void populateExampleTree(Node node, [int level = 0]) {
  if (level >= 7) return;
  node.children.addAll([
    Node(title: lorem.sentence()),
    Node(title: lorem.sentence()),
  ]);
  for (final Node child in node.children) {
    populateExampleTree(child, level + 1);
  }
}
