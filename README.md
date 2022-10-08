🚧 WIP

# flutter_fancy_tree_view [![pub package](https://img.shields.io/pub/v/flutter_fancy_tree_view.svg)](https://pub.dev/packages/flutter_fancy_tree_view)

A TreeView widget for [Flutter](https://flutter.dev).

This package provides a collection of widgets that help you bring life to your
hierarchical data.

```diff
@@ TODO: create gif and include it here @@
```

## Installation

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

## Features

  * Dynamic "Tree Node" Modeling
  * Works with any Widget
  * Indentation Guides
  * Expand/Collapse Animations
  * Keyboard Navigation
  * Rudimentary Reordering

  A simple example can be found in [example/lib/main.dart].
  There's also the [example/lib/src/samples] folder which has some
  feature specific examples.

  For a hands on experience of package features, visit the [live demo app].
  The source code for the demo app can be found [here][demo source code].

## Minimal Setup

The minimal setup is divided in three steps:
  > The below setup can be found, well commented, in [example/lib/main.dart].

  1) Create your "Tree Node" model and fulfil the `TreeNode` contract;

  ```dart
  class MyNode extends TreeNode<MyNode> with ImplicitTreeNodeId {
    MyNode({
      required this.label,
      List<MyNode>? children,
      super.isExpanded,
    }) : children = children ?? <MyNode>[];

    final String label;

    @override
    final List<MyNode> children;
  }

  // [Step 2 ...]
  ```

  2) Create a `TreeController` and provide a root node to it;
  ```dart
  // [... Step 1]

  class MyTreeView extends StatefulWidget {
    const MyTreeView({super.key});

    @override
    State<MyTreeView> createState() => _MyTreeViewState();
  }

  class _MyTreeViewState extends State<MyTreeView> {
    late final TreeController<MyNode> treeController;

    @override
    void initState() {
      super.initState();

      treeController = TreeController(
        root: MyNode(
          label: '/',
          children: [
            MyNode(
              label: 'Node 1',
              children: [
                MyNode(label: 'Child 1'),
              ],
            ),
            MyNode(label: 'Node 2'),
          ],
        ),
      );
    }

    @override
    void dispose() {
      treeController.dispose();
      super.dispose();
    }

    // [Step 3 ...]
  }
  ```
  3) Create a `TreeView` widget and provide it with the `TreeController` that
     was created on step 2 and an `itemBuilder` widget builder callback.
  ```dart
  class _MyTreeViewState extends State<MyTreeView> {
    // [... Step 2]

    @override
    Widget build(BuildContext context) {
      return TreeView<MyNode>(
        controller: treeController,
        itemBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
          return TreeItem<MyNode>(
            treeEntry: entry,
            onTap: () => treeController.toggleExpansion(entry.node),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(entry.node.label),
            ),
          );
        },
      );
    }
  }
  ```

```diff
@@ TODO @@
```

[live demo app]: https://mbaumgartenbr.github.io/flutter_tree_view
[demo source code]: https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/demo
[example/lib/main.dart]: https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/example/lib/main.dart
[example/lib/src/samples]: https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/example/lib/src/samples

[asset]: https://raw.githubusercontent.com/mbaumgartenbr/flutter_tree_view/main/.github/assets/<ASSET_FILE_NAME>
