> [!CAUTION]
> This package was **discontinued** in favor of Flutter's new [TreeSliver](https://api.flutter.dev/flutter/widgets/TreeSliver-class.html)
> widget (introduced in Flutter version 3.24.0) and
> [2D TreeView](https://pub.dev/documentation/two_dimensional_scrollables/latest/two_dimensional_scrollables/TreeView-class.html)
> from Flutter's official [two_dimensional_scrollables](https://pub.dev/packages/two_dimensional_scrollables) package.

---

# flutter_fancy_tree_view
[![pub package](https://img.shields.io/pub/v/flutter_fancy_tree_view.svg)](https://pub.dev/packages/flutter_fancy_tree_view)

A [Flutter] collection of widgets and slivers that helps bringing your
hierarchical data to life.

This package uses a set of callbacks to traverse your hierarchical data in
depth first order, collecting the needed information in a simple dart list
(the flat representation of the tree) to then lazily render the tree nodes
to the screen using slivers.

<details>
<summary><h3>Screenshots</h3></summary>

|   |   |
| - | - |
| Blank Indentation | ![IndentGuide](https://raw.githubusercontent.com/baumths/flutter_tree_view/main/screenshots/blank_indentation.png) |
| Connecting Lines  | ![IndentGuide.connectingLines](https://raw.githubusercontent.com/baumths/flutter_tree_view/main/screenshots/connecting_lines.png) |
| Scoping Lines     | ![IndentGuide.scopingLines](https://raw.githubusercontent.com/baumths/flutter_tree_view/main/screenshots/scoping_lines.png) |

</details>

<details>
<summary><h3>Installation</h3></summary>

Run this command:

```sh
flutter pub add flutter_fancy_tree_view
```

This will add a line like this to your package's pubspec.yaml (and run an 
implicit `flutter pub get`):

```yaml
dependencies:
  flutter_fancy_tree_view: any
```

Now in your Dart code, you can use:

```dart
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
```

</details>

### ⚠️ Warning
Please, treat version `1.0` as a whole new package. Migrating from previous
versions is discouraged as the package went through a major rewrite and has
many breaking changes.

## Features

* Dynamic "Tree Node" Modeling
* Works with any Widget
* Indentation Guides
* Expand/Collapse Animations
* Sliver tree variants
* Rudimentary Drag And Drop support

For a hands on experience of the features, visit the [live demo app].
The source code for the demo app can be found in the [example directory].

## Getting Started

Head over to [example/example.md] for a well commented example of the
basic usage of this package.
Also, check out the [example/lib/src/examples] folder which has some
feature specific examples.

### Usage

1. Create a "TreeNode" model to store your data

```dart
class MyTreeNode {
  const MyTreeNode({
    required this.title,
    this.children = const <MyTreeNode>[],
  });

  final String title;
  final List<MyTreeNode> children;
}
```

2. Create/Fetch your hierarchical data

```dart
final List<MyTreeNode> roots = [
  const MyTreeNode(title: 'My static root node'),
  ...fetchOtherRootNodes(),
];
```

3. Instantiate a [TreeController](https://pub.dev/documentation/flutter_fancy_tree_view/latest/flutter_fancy_tree_view/TreeController-class.html).

```dart
final treeController = TreeController<MyTreeNode>(
  roots: roots,
  childrenProvider: (MyTreeNode node) => node.children,
);
```

> **Note:**
> If you're planning on using the drag and drop feature, make sure to inlcude a
> `parentProvider` in your `TreeController`. Some methods like `expandAncestors`
> and `checkNodeHasAncestor` depend on `parentProvider` to work and will throw
> an assertion error in debug mode.

4. Pass the controller to a [TreeView](https://pub.dev/documentation/flutter_fancy_tree_view/latest/flutter_fancy_tree_view/TreeView-class.html)
and provide a widget builder to map your data into widgets. Make sure to include
a way to toggle the tree nodes' expansion state and a [TreeIndentation](https://pub.dev/documentation/flutter_fancy_tree_view/latest/flutter_fancy_tree_view/TreeIndentation-class.html)
widget to properly indent them.

```dart
@override
Widget build(BuildContext context) {
  return AnimatedTreeView<MyTreeNode>(
    treeController: treeController,
    nodeBuilder: (BuildContext context, TreeEntry<MyTreeNode> entry) {
      return InkWell(
        onTap: () => treeController.toggleExpansion(entry.node),
        child: TreeIndentation(
          entry: entry,
          child: Text(entry.node.title),
        ),
      );
    },
  );
}
```

### Drag And Drop

> For an working example, head over to the drag and drop sample code in the
> [example/lib/src/examples] directory.

This package provides two new widgets `TreeDraggable` and `TreeDragTarget`,
which wrap Flutter's [Draggable] and [DragTarget], adding some tree view
capabilities like automatically expanding/collapsing nodes on hover, auto
scrolling when dragging near the vertical edges of the scrollable's viewport,
etc.

Let's update the previous example to include the drag and drop feature.

First of all, let's update our "TreeNode" model to include a reference to the
parent node, this is an important step to make sure the auto expand/collapse
behavior works properly.

```dart
class MyTreeNode {
  MyTreeNode({
    required this.title,
    Iterable<MyTreeNode>? children,
  }) : children = <MyTreeNode>[] {
    if (children == null) return;

    for (final MyTreeNode child in children) {
      this.children.add(child);

      // Make sure to update the parent of your nodes when updating the children
      // of a given node.
      child.parent = this;
    }
  }

  final String title;
  final List<MyTreeNode> children;
  MyTreeNode? parent;
}
```

With our model updated, let's make sure our `TreeController` includes a
`parentProvider` callback to access the ancestors of a given tree node.
This is extremely important for the drag and drop feature and also for
methods like `expandAncestors`. If `parentProvider` is not defined, a
callback that always returns null (e.g., `(MyTreeNode node) => null`)
is used instead and the methods that require it will throw an assertion
error in debug mode.

```dart
final treeController = TreeController<MyTreeNode>(
  ...,
  parentProvider: (MyTreeNode node) => node.parent,
);
```

Now, let's update our tree node widget to include the `TreeDraggable` and
`TreeDragTarget` widgets.

```dart
@override
Widget build(BuildContext context) {
  return AnimatedTreeView<MyTreeNode>(
    treeController: treeController,
    nodeBuilder: (BuildContext context, TreeEntry<MyTreeNode> entry) {
      return TreeDragTarget<MyTreeNode>(
        node: entry.node,
        onNodeAccepted: (TreeDragAndDropDetails details) {
          // Optionally make sure the target node is expanded so the dragging
          // node is visible in its new vicinity when the tree gets rebuilt.
          treeController.setExpansionState(details.targetNode, true);

          // TODO: implement your tree reorder logic

          // Make sure to rebuild your tree view to show the reordered nodes
          // in their new vicinity.
          treeController.rebuild();
        },
        builder: (BuildContext context, TreeDragAndDropDetails? details) {
          Widget myTreeNodeTile = Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(entry.node.title),
          );

          // If details is not null, a dragging tree node is hovering this
          // drag target. Add some decoration to give feedback to the user.
          if (details != null) {
            myTreeNodeTile = ColoredBox(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              child: myTreeNodeTile,
            );
          }

          return TreeDraggable<MyTreeNode>(
            node: entry.node,

            // Show some feedback to the user under the dragging pointer,
            // this can be any widget.
            feedback: IntrinsicWidth(
              child: Material(
                elevation: 4,
                child: myTreeNodeTile,
              ),
            ),

            child: InkWell(
              onTap: () => treeController.toggleExpansion(entry.node),
              child: TreeIndentation(
                entry: entry,
                child: myTreeNodeTile,
              ),
            ),
          );
        },
      );
    },
  );
}
```

[Draggable]: https://api.flutter.dev/flutter/widgets/Draggable-class.html
[DragTarget]: https://api.flutter.dev/flutter/widgets/DragTarget-class.html

## API Documentation

Head over to the [pub.dev api docs].

[Flutter]: https://flutter.dev
[live demo app]: https://baumths.github.io/flutter_tree_view
[example directory]: https://github.com/baumths/flutter_tree_view/tree/main/example
[example/example.md]: https://github.com/baumths/flutter_tree_view/tree/main/example/example.md
[example/lib/src/examples]: https://github.com/baumths/flutter_tree_view/tree/main/example/lib/src/examples
[pub.dev api docs]: https://pub.dev/documentation/flutter_fancy_tree_view/latest/flutter_fancy_tree_view/flutter_fancy_tree_view-library.html
