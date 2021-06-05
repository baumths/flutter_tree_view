import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fancy_tree_view/src/tree_node.dart';
import 'package:flutter_fancy_tree_view/src/tree_view_controller.dart';

void main() {
  late TreeNode root;
  late TreeNode node1;
  late TreeNode node11;
  late TreeNode node12;
  late TreeNode node121;
  late TreeNode node2;
  late TreeNode node21;

  late TreeViewControllerBase controller;

  setUp(() {
    root = TreeNode(id: '-1');
    node1 = TreeNode(id: '1');
    node11 = TreeNode(id: '11');
    node12 = TreeNode(id: '12');
    node121 = TreeNode(id: '121');
    node2 = TreeNode(id: '2');
    node21 = TreeNode(id: '21');

    node2.addChild(node21);
    node12.addChild(node121);
    node1.addChildren([node11, node12]);
    root.addChildren([node1, node2]);

    controller = TreeViewControllerBase(rootNode: root);
  });
  group('TreeViewController Tests -', () {
    test(
      'Should populate rootNode correctly.',
      () {
        expect(controller.rootNode, root);
      },
    );

    test(
      'Should have visibleNodes populated with node1, node2 and not root.',
      () {
        expect(controller.visibleNodes, isNot(contains(root)));

        expect(controller.visibleNodes, containsAll([node1, node2]));
      },
    );

    test(
      'Should return the right value '
      'When a node is Expanded.',
      () {
        expect(controller.isExpanded(node1.id), isFalse);

        controller.expandNode(node1);

        expect(controller.isExpanded(node1.id), isTrue);

        controller.collapseNode(node1);

        expect(controller.isExpanded(node1.id), isFalse);
      },
    );

    test(
      'Should populate visibleNodes with node1.children '
      'When expandNode is called with node1.',
      () {
        expect(controller.visibleNodes, isNot(containsAll(node1.children)));

        controller.expandNode(node1);

        expect(controller.visibleNodes, containsAll(node1.children));
      },
    );

    test(
      'Should remove node1.children from visibleNodes '
      'When collapseNode is called with node1.',
      () {
        expect(controller.visibleNodes, isNot(containsAll(node1.children)));
        controller.expandNode(node1);
        expect(controller.visibleNodes, containsAll(node1.children));

        controller.collapseNode(node1);

        expect(controller.visibleNodes, isNot(containsAll(node1.children)));
      },
    );

    test(
      'Should not remove node1 and node2 from visibleNodes '
      'When collapseNode is called with root.',
      () {
        expect(controller.visibleNodes, containsAll([node1, node2]));

        controller.collapseNode(root);

        expect(controller.visibleNodes, containsAll([node1, node2]));
      },
    );

    test(
      'Should toggle the state of node1 correctly '
      'When toggleExpanded is called on node1.',
      () {
        expect(controller.visibleNodes, isNot(containsAll(node1.children)));

        controller.toggleExpanded(node1);

        expect(controller.isExpanded(node1.id), isTrue);
        expect(controller.visibleNodes, containsAll(node1.children));

        controller.toggleExpanded(node1);

        expect(controller.isExpanded(node1.id), isFalse);
        expect(controller.visibleNodes, isNot(containsAll(node1.children)));
      },
    );

    test(
      'Should expand the entire tree '
      'When expandSubtree is called with root.',
      () {
        expect(controller.visibleNodes, [node1, node2]);

        controller.expandSubtree(root);

        expect(controller.isExpanded(root.id), isTrue);
        expect(controller.isExpanded(node1.id), isTrue);
        expect(controller.isExpanded(node12.id), isTrue);
        expect(controller.isExpanded(node2.id), isTrue);

        expect(
          controller.visibleNodes,
          [node1, node11, node12, node121, node2, node21],
        );
      },
    );

    test(
      'Should expand every ascendant of node121 '
      'When controller.expandUntil is called with node121.',
      () {
        expect(controller.isExpanded(node121.id), isFalse);

        controller.expandUntil(node121);

        expect(
          controller.visibleNodes,
          [node1, node11, node12, node121, node2],
        );
        expect(controller.isExpanded(node121.id), isFalse);
      },
    );
  });

  test(
    'Should render a newly added node to the tree without keeping '
    'the expansion state of nodes '
    'When refreshNode is called.',
    () {
      controller.expandNode(node1);

      final newNode = TreeNode(id: 'NewNode');
      root.addChild(newNode);

      expect(controller.visibleNodes, [node1, node11, node12, node2]);

      controller.refreshNode(root);

      expect(controller.visibleNodes, [node1, node2, newNode]);
    },
  );

  test(
    'Should render a newly added node to the tree '
    'keeping the expansion state of nodes '
    'When refreshNode is called with keepExpandedNodes set to true.',
    () {
      controller.expandNode(node1);

      final newNode = TreeNode(id: 'NewNode');
      root.addChild(newNode);

      expect(controller.visibleNodes, [node1, node11, node12, node2]);

      controller.refreshNode(root, keepExpandedNodes: true);

      expect(controller.visibleNodes, [node1, node11, node12, node2, newNode]);
    },
  );

  test(
    'Should not display a node that was removed from the tree '
    'When refreshNode is called after deleting a node.',
    () {
      final allNodes = root.descendants.toList();
      controller.expandSubtree(root);
      expect(controller.visibleNodes, allNodes);

      // Delete node12 moving it's child node121 to the children of node1.
      node12.delete();
      controller.refreshNode(node1);

      expect(controller.visibleNodes, [node1, node11, node121, node2, node21]);
    },
  );

  test(
    'Should correctly display the new top level node '
    'When refreshNode is called after moving a node to the children of root.',
    () {
      final allNodes = root.descendants.toList();
      controller.expandSubtree(root);
      expect(controller.visibleNodes, allNodes);

      root.addChild(node11);
      controller.refreshNode(root, keepExpandedNodes: true);

      expect(
        controller.visibleNodes,
        [node1, node12, node121, node2, node21, node11],
      );
    },
  );

  test(
    'Should correctly display the new hierarchy '
    'When refreshNode is called after moving a node to a different parent.',
    () {
      final allNodes = root.descendants.toList();
      controller.expandSubtree(root);
      expect(controller.visibleNodes, allNodes);

      node121.addChild(node11);
      controller.refreshNode(node1, keepExpandedNodes: true);

      expect(
        controller.visibleNodes,
        [node1, node12, node121, node11, node2, node21],
      );
    },
  );

  test(
    'Should correctly display swapped parent and child '
    'When refreshNode is called.',
    () {
      final allNodes = root.descendants.toList();
      controller.expandSubtree(root);
      expect(controller.visibleNodes, allNodes);

      node1.addChild(node121);
      node121.addChild(node12);

      expect(node12.children, isEmpty);
      expect(node121.children, {node12});

      controller.refreshNode(node1, keepExpandedNodes: true);

      expect(
        controller.visibleNodes,
        [node1, node11, node121, node12, node2, node21],
      );
    },
  );
}
