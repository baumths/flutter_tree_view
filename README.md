🚧 WIP

# flutter_fancy_tree_view [![pub package](https://img.shields.io/pub/v/flutter_fancy_tree_view.svg)](https://pub.dev/packages/flutter_fancy_tree_view)

A TreeView widget for [Flutter](https://flutter.dev).

This package provides a collection of widgets that help you bring life to your
hierarchical data.

```diff
@@ TODO: create gif and include it here @@
```

<details>
<summary>

### Installation

</summary>

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

## Features

* Dynamic "Tree Node" Modeling
* Works with any Widget
* Indentation Guides
* Expand/Collapse Animations
* ~~Keyboard Navigation~~ (being reworked)

* Rudimentary Drag and Drop support

A simple example can be found in [example/lib/main.dart].
There's also the [example/lib/src/samples] folder which has some
feature specific examples.

For a hands on experience with the features, visit the [live demo app].
The source code for the demo app can be found [here][demo source code].

## Minimal Setup

> The below setup can be found, well commented, in [example/lib/main.dart].

The minimal setup is divided in three steps:

1) Create your "tree node" model and fulfil the `TreeNode` interface:
```dart
class MyNode extends TreeNode<MyNode> {
  MyNode({
    required this.label,
    List<MyNode>? children,
    super.isExpanded,
  }) : children = children ?? <MyNode>[];

  final String label;

  @override
  final List<MyNode> children;
}
```

2) Create your nodes:
```dart
class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  late List<MyNode> roots;

  @override
  void initState() {
    super.initState();

    roots = <MyNode>[
      MyNode(
        label: 'Root 1',
        isExpanded: true,
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
      MyNode(label: 'Root 2'),
    ];
  }

  // [Step 3 ...]
}
```
3) Create a `TreeView` widget and provide it with the list of root nodes that 
 was created on step 2 and the `itemBuilder` widget builder callback that 
 will be used to map your nodes into widgets:
```dart
class _MyTreeViewState extends State<MyTreeView> {
  // [... Step 2]

  @override
  Widget build(BuildContext context) {
    return TreeView<MyNode>(
      roots: roots,
      itemBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
        return TreeItem(
          onTap: () => TreeView.of<MyNode>(context).toggleExpansion(entry.node),
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

## Going deeper

### `SliverTreeState.rebuild()`
The `SliverTreeState.rebuild()` method can be used to update the internal 
flattened tree. This method is the core of this tree API, it should be called 
every time the tree structure changes in any way (i.e., the expansion state 
of a node changed, nodes were added/removed from the tree, a node/subtree was 
reordered, etc...).

<details>
<summary>

#### The `animate` flag

</summary>

The `animate` flag (which defaults to `true`) is used to do an additional 
check when flattening the tree to verify if the expansion state of a node 
changed relative to the previous flattened tree, if it did, the node id is 
added to a `Set` and its descendants will animate in/out when the flattening 
finishes. The animating nodes are all rendered in a column along with their 
parent while the animaiton is running, when the animation finishes, the tree 
is flattened again to add/remove the nodes that were animating from the 
flattened tree list and its id is removed from the `Set` cache.

</details>

### TreeEntry
The `TreeEntry` holds important information about the context of its 
`TreeEntry.node` in the _current_ flattened tree. Every time the tree is 
flattened a new instance of `TreeEntry` is created with fresh values for 
each node, like the index, level, parent, etc...

### Indentation Guides
| IndentGuide type | Picture |
| ---------------- | :-----: |
| Blank            |   pic   |
| Connecting Lines |   pic   |
| Scoping Lines    |   pic   |
| Colored Levels   |  _TBD_  |

<details>
<summary>

#### The `TreeIndentation` Widget

</summary>

The `TreeIndentation` widget is used to both indent each node depending 
on its level and to paint indentation guides if desired.
Each `TreeIndentation` can have its own `IndentGuide` settings, which if 
not provided, the `TreeIndentation` will look for a `DefaultIndentGuide` 
(`InheritedTheme`) up the widget tree, which, if not found, defaults to 
a constant `ConnectingLinesGuide` with its constructor default values.

</details>

### Drag and Drop

### Keyboard Navigation

[live demo app]: https://mbaumgartenbr.github.io/flutter_tree_view
[demo source code]: https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/demo
[example/lib/main.dart]: https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/example/lib/main.dart
[example/lib/src/samples]: https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/example/lib/src/samples

[asset]: https://raw.githubusercontent.com/mbaumgartenbr/flutter_tree_view/main/.github/assets/<ASSET_FILE_NAME>
