import 'package:flutter_fancy_tree_view/src/internal.dart';
import 'package:flutter_test/flutter_test.dart';

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
        expect(controller.rootNode, equals(root));
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
        expect(controller.isExpanded(root.id), isTrue);

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

        expect(controller.isExpanded(root.id), isTrue);
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
        expect(controller.visibleNodes, equals([node1, node2]));

        controller.expandSubtree(root);

        expect(controller.isExpanded(root.id), isTrue);
        expect(controller.isExpanded(node1.id), isTrue);
        expect(controller.isExpanded(node12.id), isTrue);
        expect(controller.isExpanded(node2.id), isTrue);

        expect(
          controller.visibleNodes,
          equals([node1, node11, node12, node121, node2, node21]),
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
          equals([node1, node11, node12, node121, node2]),
        );
        expect(controller.isExpanded(node121.id), isFalse);
      },
    );
  });
}
