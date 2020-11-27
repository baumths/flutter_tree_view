import 'package:flutter/foundation.dart';
import 'package:flutter_tree_view/flutter_tree_view.dart';

List<TreeNode> mapHierarchicalData(
  List<Map<String, dynamic>> children,
) {
  if (children.isEmpty) return const [];

  return children.map((child) {
    final node = TreeNode(
      key: ValueKey<int>(int.parse(child['name'].split('.').join())),
      data: child['name'],
    );

    if (child['children'] != null) {
      node.addChildren(mapHierarchicalData(child['children']));
    }

    return node;
  }).toList(growable: false);
}

TreeNode generateTreeNodes(List<Map<String, dynamic>> maps) {
  return TreeNode(data: 'Root')..addChildren(mapHierarchicalData(maps));
}
