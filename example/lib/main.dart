import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'src/sample_data.dart';
import 'src/home_page.dart';

void main() => runApp(MyApp());

/// Recursively convert a list of maps into a list of [TreeNode]s.
List<TreeNode> generateTreeNodes(List<Map<String, dynamic>> children) {
  if (children.isEmpty) return const [];

  return children.map((child) {
    return TreeNode(
      id: '${child['id'] ?? ''}',
      label: child['name'] ?? '',
    )..addChildren(generateTreeNodes(child['children'] ?? const []));
  }).toList(growable: false);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TreeNode _rootNode;

  TreeNode buildTreeStructure() {
    return TreeNode(id: 'ROOT')..addChildren(generateTreeNodes(sampleData));
  }

  @override
  void initState() {
    super.initState();
    _rootNode = buildTreeStructure();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TreeView Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kDarkBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        iconTheme: const IconThemeData(color: kDarkBlue),
      ),
      home: HomePage(rootNode: _rootNode),
    );
  }
}
