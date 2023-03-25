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

## API Documentation

Head over to the [pub.dev api docs].

[Flutter]: https://flutter.dev
[live demo app]: https://baumths.github.io/flutter_tree_view
[example directory]: https://github.com/baumths/flutter_tree_view/tree/main/example
[example/example.md]: https://github.com/baumths/flutter_tree_view/tree/main/example/example.md
[example/lib/src/examples]: https://github.com/baumths/flutter_tree_view/tree/main/example/lib/src/examples
[pub.dev api docs]: https://pub.dev/documentation/flutter_fancy_tree_view/latest/flutter_fancy_tree_view/flutter_fancy_tree_view-library.html
