import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_tree_view/src/tree_node.dart';

void main() {
  late TreeNode root;
  late TreeNode node1;
  late TreeNode node2;

  setUp(() {
    root = TreeNode(data: 'Root');
    node1 = TreeNode(key: const ValueKey<int>(1), data: '1');
    node2 = TreeNode(key: const ValueKey<int>(2), data: '2');
  });

  group('Tests for children -', () {
    test(
      'Should add node1 to root.children when addChild is called with node1 on root.',
      () {
        expect(root.children, isEmpty);

        root.addChild(node1);

        expect(root.children, isNotEmpty);
        expect(root.children, hasLength(1));
        expect(root.children.first, equals(node1));
      },
    );

    test(
      'Should set root as parent of node1 when addChild is called with node1 on root.',
      () {
        expect(node1.parent, isNull);

        root.addChild(node1);

        expect(node1.parent, isNotNull);
        expect(node1.parent, equals(root));
      },
    );

    test(
      'Should add node1 and node2 to root.children when addChildren is called with [node1, node2] on root.',
      () {
        expect(root.children, isEmpty);

        root.addChildren([node1, node2]);

        expect(root.children, isNotEmpty);
        expect(root.children, hasLength(2));
        expect(root.children, equals([node1, node2]));
      },
    );

    test(
      'Should set root as parent of node1 and node2 when addChildren is called with [node1, node2] on root.',
      () {
        expect(node1.parent, isNull);
        expect(node2.parent, isNull);

        root.addChildren([node1, node2]);

        expect(node1.parent, isNotNull);
        expect(node1.parent, equals(root));

        expect(node2.parent, isNotNull);
        expect(node2.parent, equals(root));
      },
    );

    test(
      'Should change the parent of node1 and remove it from its parent children when it is added to another node.',
      () {
        expect(node1.parent, isNull);

        root.addChild(node1);
        expect(node1.parent, equals(root));
        expect(root.children.first, equals(node1));

        node2.addChild(node1);
        expect(node1.parent, equals(node2));
        expect(node2.children.first, equals(node1));

        expect(root.children, isEmpty);
      },
    );

    test(
      'Should remove node1 from root.children and set its parent to null when removeChild is called on root with node1.',
      () {
        root.addChild(node1);

        root.removeChild(node1);

        expect(root.children, isEmpty);
        expect(node1.parent, isNull);
      },
    );
  });

  group('Tests for parent -', () {
    setUp(() {
      root.addChildren([node1, node2]);
    });

    test(
      'Should return null for root and root for node1 and node2 when parent getter is called.',
      () {
        expect(root.parent, isNull);

        expect(node1.parent, isNotNull);
        expect(node1.parent, equals(root));

        expect(node2.parent, isNotNull);
        expect(node2.parent, equals(root));
      },
    );
  });

  group('Tests for depth', () {
    setUp(() {
      root.addChild(node1);
      node1.addChild(node2);
    });

    test(
      'Should return 0 when called on root',
      () {
        expect(root.depth, equals(0));
      },
    );

    test(
      'Should return 1 when called on node1',
      () {
        expect(node1.depth, equals(1));
      },
    );

    test(
      'Should return 2 when called on node2',
      () {
        expect(node2.depth, equals(2));
      },
    );
  });
}
