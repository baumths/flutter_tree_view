## [1.0.0] 20-03-2023
### ⚠️ Warning: Major Rewrite
Please, treat this version as a whole new package. Migrating from previous
versions is discouraged as the package went through a major rewrite and has
many breaking changes.

---

#### Additions:
- Dynamic "TreeNode" modeling through callbacks
- `IndentGuides` indentation decorations API
- `SliverTree` and `SliverAnimatedTree` slivers
- `AnimatedTreeView` widget
- `TreeEntry` tree node details object

#### Changes:
- Renamed `TreeViewController` to `TreeController`
  - Removed: `find()`, `shouldRefresh()`, `nodeRefreshed()`, `refreshNode()`,
    `reset()`, `nodeAt()`, `isVisible()`, `indexOf()`, `expandAll()`,
    `collapseAll()`, `useBinarySearch`, `rootNode`, `visibleNodes`,
    `expandedNodes`
  - Renamed methods:
    | Old               | New                 |
    | :---------------- | :------------------ |
    | `expandNode`      | `expand`            |
    | `collapseNode`    | `collapse`          |
    | `toggleExpanded`  | `toggleExpansion`   |
    | `expandSubtree`   | `expandCascading`   |
    | `collapseSubtree` | `collapseCascading` |
    | `expandUntil`     | `expandAncestors`   |
    | `isExpanded`      | `getExpansionState` |
  - Added: `roots`, `childrenProvider()`, `setExpansionState()`, `rebuild()`,
    `depthFirstTraversal()`
- `NodeWidgetLeadingIcon` was rewritten as `FolderButton`

#### Removals:
- Removed `nodeHeight` from `TreeView` (fixed height not required anymore)
- Removed `TreeViewControllerBase`
- Removed `TreeNode` and `TreeNodeScope`
- Removed `NodeWidget` as it was just a wrapper around `InkWell` + `Row`
- Removed `ExpandNodeIcon` as it was just a wrapper around `ExpandIcon`
- Removed `TreeViewTheme`, `LinesWidget`, `LinesPainter` and `TreeLine`
  in favor of the new `IndentGuide` + `TreeIndentation` API.

## [0.5.3+2] 01-10-2022
- Update [NodeWidgetLeadingIcon] icon types from [Icon] to [Widget]
  - Author: @naory159 (https://github.com/naory159)

## [0.5.3+1] 12-08-2022
- Fix rtl line painting bug
  - Author: @naory159 (https://github.com/naory159)

## [0.5.3] 09-08-2022
- Add Right-to-Left support to line painting
  - Author: @naory159 (https://github.com/naory159)

## [0.5.2] 29-06-2022
- Allow [TreeView.nodeHeight] to be nullable.
  - Author: @mz2 (https://github.com/mz2)

## [0.5.1+1] 10-06-2021
- Fixes logic that marks nodes to refresh
  
  > Before only child nodes were getting marked as needing refresh,
  > causing the grand children and it's subtrees not to refresh,
  > breaking lines hierarchy.


## [0.5.1] 10-06-2021
- Adds new refreshNode Feature to [TreeViewController]
- Updates TreeNode's [delete] and [clearChildren] logic
- Adds linesToBeDrawn check in shouldRepaint of [LinesPainter]

- New example App UI

## [0.5.0] 30-05-2021
### Reverts most changes from 0.4.0

* Removing the TreeViewController made nodes inside a different page or in
  a drawer to lose their state.
  - TreeViewController is back, all logic from _TreeViewState got moved back
    to it.

* Merged the utils methods into TreeNode (ancestors, descendants, ...).

* The TreeView no longer auto scrolls nodes.
  - Now scrolling has to be done by the user.


## [0.4.0] 17-05-2021
### Simplification of the TreeView API.
  
* Dropped TreeViewController and merged it's logic into [TreeViewState]
  to make the code less 'spaghetti'. Instead of the controller, use a
  [GlobalKey<TreeViewState>] to control the [TreeView] from outside of
  it's widget subtree and [TreeView.of] from within it's widget subtree.
  - Made [TreeViewState] not private anymore.

* New scrolling functionality.
    - Added [scrollController] optional property to [TreeView].

    - Added [shouldAutoScroll] property to [TreeView].

    - Added [scrollTo] method to [TreeViewState].

* Renamed ScopedTreeNode to TreeNodeScope.

* Renamed InheritedTreeView to _TreeViewScope.

* Removed `reversedSubtreeGenerator` from `utils.dart` as it was not being used.

## [0.3.1] 16-04-2021
* Implemented rounded corners for connected lines.

## [0.3.0] 15-04-2021

* [ExpandNodeIcon] and [NodeWidgetLeadingIcon] are able to expand/collapse
  leaf nodes.

* [TreeNode.children] changed from [List] to [Set] to avoid duplicate children.

* The [TreeViewController] received a new callback.
  - The new `onAboutToExpand` is useful to dynamically populate the [TreeView].

* Some performance improvements when expanding/collapsing nodes.

## [0.2.1] 11-04-2021

* Added useBinarySearch option to TreeViewController.

* Many performance improvements by reducing the amount of loops that
  expandNode and collapseNode took.

## [0.2.0] 31-03-2021

* Stable null safety release.

* Refactoring of the entire API:
    - The old API was very "janky" with AnimatedList, TreeView now uses
      ListView.custom under the hood.

    - New InheritedTreeView inherited widget  is used under the hood to get
      access to TreeViewController and TreeViewTheme from TreeView.of() method.

    - New ScopedTreeNode inherited widget, to get a TreeNode from anywhere
      under it in the widget tree, every TreeNode has its own ScopedTreeNode.

    - New NodeWidgetLeadingIcon for a folder/file icon approach.

    - The TreeViewController is now a ChangeNotifier, to talk to TreeView more
      easily.

    - TreeNode received a delete() method that removes it from the tree and
      clear its relationships.

* Extracted the main implementation of TreeViewController to a base class
  to be able to change the expansion of a node without notifying listeners. 
    - Added some tests to TreeViewControllerBase.

* Updated NodeWidget to a Row instead of a ListTile
    - ListTile had some errors when using LinesWidget as leading.

* Dropped support for selecting/disabling nodes as it was getting very
  complicated and "hacky" to manage.

* Dropped TreeLine.link as it was complicating the indentation of nodes.

* Plus Many upgrades and fixes.

## [0.1.0-nullsafety.0] 12-02-2021

* First release.
