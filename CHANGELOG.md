## [0.3.0] 11-04-2021

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
