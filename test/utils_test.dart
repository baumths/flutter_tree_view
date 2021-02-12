import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fancy_tree_view/src/internal.dart';

void main() {
  late TreeNode rootNode;
  late TreeNode node1;
  late TreeNode node11;
  late TreeNode node111;
  late TreeNode node12;
  late TreeNode node121;
  late TreeNode node122;
  late TreeNode node2;

  late List<TreeNode> rootSubtree;

  setUp(() {
    rootNode = TreeNode(data: 'Root');
    node1 = TreeNode(data: '1');
    node11 = TreeNode(data: '11');
    node111 = TreeNode(data: '111');
    node12 = TreeNode(data: '12');
    node121 = TreeNode(data: '121');
    node122 = TreeNode(data: '122');
    node2 = TreeNode(data: '2');

    node11.addChild(node111);
    node12.addChildren([node121, node122]);
    node1.addChildren([node11, node12]);
    rootNode.addChildren([node1, node2]);

    rootSubtree = [node1, node11, node111, node12, node121, node122, node2];
  });

  group('Tests for subtreeGenerator -', () {
    late List<TreeNode> node1Subtree;
    late List<TreeNode> node11Subtree;
    late List<TreeNode> node12Subtree;

    setUp(() {
      node1Subtree = [node11, node111, node12, node121, node122];
      node11Subtree = [node111];
      node12Subtree = [node121, node122];
    });
    test(
      'Should return a list of length 7 that match rootSubtree '
      'when called with rootNode.',
      () {
        final result = subtreeGenerator(rootNode);
        expect(result, hasLength(7));
        expect(result, equals(rootSubtree));
      },
    );

    test(
      'Should return a list of length 5 that match node1Subtree '
      'when called with node1.',
      () {
        final result = subtreeGenerator(node1);
        expect(result, hasLength(5));
        expect(result, equals(node1Subtree));
      },
    );

    test(
      'Should return a list of length 1 that match node11Subtree '
      'when called with node11.',
      () {
        final result = subtreeGenerator(node11);
        expect(result, hasLength(1));
        expect(result, equals(node11Subtree));
      },
    );

    test(
      'Should return a list of length 2 that match node12Subtree '
      'when called with node12.',
      () {
        final result = subtreeGenerator(node12);
        expect(result, hasLength(2));
        expect(result, equals(node12Subtree));
      },
    );

    test(
      'Should return an empty list each '
      'when called with: node111, node121, node122, node2.',
      () {
        expect(subtreeGenerator(node111), isEmpty);

        expect(subtreeGenerator(node121), isEmpty);

        expect(subtreeGenerator(node122), isEmpty);

        expect(subtreeGenerator(node2), isEmpty);
      },
    );
  });

  group('Tests for reversedSubtreeGenerator -', () {
    late List<TreeNode> reversedRootSubtree;
    setUp(() {
      reversedRootSubtree = rootSubtree.reversed.toList(growable: false);
    });

    test(
      'Should return reversedRootSubtree '
      'when called with rootNode',
      () {
        expect(reversedSubtreeGenerator(rootNode), equals(reversedRootSubtree));
      },
    );
  });

  group('Tests for findPathFromRoot -', () {
    late List<TreeNode> ancestorsOfNode111;
    late List<TreeNode> ancestorsOfNode122;
    setUp(() {
      ancestorsOfNode111 = [rootNode, node1, node11, node111];
      ancestorsOfNode122 = [rootNode, node1, node12, node122];
    });

    test(
      'Should return ancestorsOfNode111 when called on node111',
      () {
        final result = findPathFromRoot(node111).toList(growable: false);
        expect(result, equals(ancestorsOfNode111));
      },
    );

    test(
      'Should return ancestorsOfNode122 when called on node122',
      () {
        final result = findPathFromRoot(node122).toList(growable: false);
        expect(result, equals(ancestorsOfNode122));
      },
    );
  });
}
