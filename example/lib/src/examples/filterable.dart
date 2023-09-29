import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

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

    Pattern searchPattern = query.maybeToRegex();
    filter = treeController.search(
      (Node node) => node.title.contains(searchPattern),
    );
    treeController.rebuild();

    if (mounted) {
      setState(() {});
    }
  }

  void clearSearch() {
    if (filter == null) return;

    setState(() {
      filter = null;
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
    treeController.dispose();
    searchBarTextEditingController.dispose();
    super.dispose();
  }

  String get counter => '${filter?.totalMatchCount}/${filter?.totalNodeCount}';

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BadgeTheme(
      data: BadgeThemeData(
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
      ),
      child: Column(
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
                  label: Text(counter),
                  isLabelVisible: filter != null,
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearSearch,
                )
              ],
            ),
          ),
          Expanded(
            child: TreeView<Node>(
              treeController: treeController,
              nodeBuilder: (BuildContext context, TreeEntry<Node> entry) {
                return MyTreeTile(
                  entry: entry,
                  match: filter?.matchOf(entry.node),
                  hasActiveFilter: filter != null,
                  onPressed: entry.hasChildren
                      ? (_) => treeController.toggleExpansion(entry.node)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.entry,
    required this.match,
    required this.onPressed,
    this.hasActiveFilter = false,
  });

  final TreeEntry<Node> entry;
  final TreeSearchMatch? match;
  final ValueChanged<bool>? onPressed;
  final bool hasActiveFilter;

  @override
  Widget build(BuildContext context) {
    final bool isDirectMatch = match?.isDirectMatch ?? false;

    return TreeIndentation(
      entry: entry,
      child: Row(
        children: [
          ExpandIcon(
            key: GlobalObjectKey(entry.node),
            isExpanded: entry.isExpanded,
            onPressed: onPressed,
          ),
          if (!entry.isExpanded && (match?.subtreeMatchCount ?? 0) > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Badge(
                label: Text('${match?.subtreeMatchCount}'),
              ),
            ),
          Flexible(
            child: Opacity(
              opacity: !hasActiveFilter || isDirectMatch ? 1 : 0.5,
              child: Text(entry.node.title),
            ),
          ),
        ],
      ),
    );
  }
}

extension on String {
  Pattern maybeToRegex() {
    try {
      return RegExp(this);
    } on FormatException {
      return this;
    }
  }
}

final lorem = Faker().lorem;
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
