import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fancy_tree_view/src/tree_node.dart';

void main() {
  late TreeNode root;
  late TreeNode node1;
  late TreeNode node2;

  setUp(() {
    root = TreeNode(id: '-1');
    node1 = TreeNode(id: '1');
    node2 = TreeNode(id: '2');
  });

  group('Tests for children -', () {
    test(
      'Should not add duplicate child.',
      () {
        expect(root.children, isEmpty);

        root.addChild(node1);

        expect(root.children, hasLength(1));
        expect(root.children, [node1]);

        root.addChild(node1);

        expect(root.children, hasLength(1));
        expect(root.children, [node1]);
      },
    );

    test(
      'Should add node1 to root.children '
      'When addChild is called with node1 on root.',
      () {
        expect(root.children, isEmpty);

        root.addChild(node1);

        expect(root.children, isNotEmpty);
        expect(root.children, hasLength(1));
        expect(root.children.first, node1);
      },
    );

    test(
      'Should set root as parent of node1 '
      'When addChild is called with node1 on root.',
      () {
        expect(node1.parent, isNull);

        root.addChild(node1);

        expect(node1.parent, isNotNull);
        expect(node1.parent, root);
      },
    );

    test(
      'Should add node1 and node2 to root.children '
      'When addChildren is called with [node1, node2] on root.',
      () {
        expect(root.children, isEmpty);

        root.addChildren([node1, node2]);

        expect(root.children, isNotEmpty);
        expect(root.children, hasLength(2));
        expect(root.children, [node1, node2]);
      },
    );

    test(
      'Should set root as parent of node1 and node2 '
      'When addChildren is called with [node1, node2] on root.',
      () {
        expect(node1.parent, isNull);
        expect(node2.parent, isNull);

        root.addChildren([node1, node2]);

        expect(node1.parent, isNotNull);
        expect(node1.parent, root);

        expect(node2.parent, isNotNull);
        expect(node2.parent, root);
      },
    );

    test(
      'Should change the parent of node1 and remove it from its parent children '
      'When it is added to another node.',
      () {
        expect(node1.parent, isNull);

        root.addChild(node1);
        expect(node1.parent, root);
        expect(root.children.first, node1);

        node2.addChild(node1);
        expect(node1.parent, node2);
        expect(node2.children.first, node1);

        expect(root.children, isEmpty);
      },
    );

    test(
      'Should remove node1 from root.children and set its parent to null '
      'When removeChild is called on root with node1.',
      () {
        root.addChild(node1);

        root.removeChild(node1);

        expect(root.children, isEmpty);
        expect(node1.parent, isNull);
      },
    );

    test(
      'Should NOT add node1 to the children of node2 '
      'When node1 is parent of node2 and node2.addChild is called with node1.',
      () {
        node1.addChild(node2);
        expect(node2.children, isEmpty);

        node2.addChild(node1);
        expect(node2.children, isEmpty);

        expect(node2.parent, node1);

        expect(node1.children, hasLength(1));
        expect(node1.children, [node2]);
      },
    );
  });
  group('Tests for descendants -', () {
    late TreeNode node11;
    late TreeNode node21;

    setUp(() {
      node11 = TreeNode(id: '1.1');
      node21 = TreeNode(id: '2.1');

      node1.addChild(node11);
      node2.addChild(node21);
      root.addChildren([node1, node2]);
    });

    tearDown(() {
      root.clearChildren();
      node1.clearChildren();
      node2.clearChildren();
    });

    test(
      'Should return a list of length 4 that match rootSubtree '
      'When root.descendants.toList is called.',
      () {
        final result = root.descendants.toList();
        expect(result, hasLength(4));
        expect(result, [node1, node11, node2, node21]);
      },
    );

    test(
      'Should return a list of length 1 '
      'When node1.descendants.toList is called.',
      () {
        final result = node1.descendants.toList();
        expect(result, hasLength(1));
        expect(result, [node11]);
      },
    );

    test(
      'Should return an empty list '
      'When node11.descendants.toList is called.',
      () {
        final result = node11.descendants.toList();
        expect(result, isEmpty);
      },
    );
  });

  group('Tests for parent -', () {
    group('parent -', () {
      setUp(() {
        root.addChildren([node1, node2]);
      });

      test(
        'Should return null for root and root for node1 and node2 '
        'When parent getter is called.',
        () {
          expect(root.parent, isNull);

          expect(node1.parent, isNotNull);
          expect(node1.parent, root);

          expect(node2.parent, isNotNull);
          expect(node2.parent, root);
        },
      );
    });
    group('ancestors -', () {
      setUp(() {
        root.addChild(node1);
        node1.addChild(node2);
      });
      test(
        'Should return ancestorsOfNode2 When node2.ancestors is called.',
        () {
          expect(node2.ancestors.toList(), [root, node1]);
        },
      );
    });
  });

  group('Tests for depth -', () {
    setUp(() {
      root.addChild(node1);
      node1.addChild(node2);
    });

    test(
      'Should return -1 When called on root.',
      () {
        expect(root.depth, -1);
      },
    );

    test(
      'Should return 0 When called on node1.',
      () {
        expect(node1.depth, 0);
      },
    );

    test(
      'Should return 1 When called on node2.',
      () {
        expect(node2.depth, 1);
      },
    );
  });

  group('Tests for methods -', () {
    group('delete -', () {
      late TreeNode grandChildNode1;
      late TreeNode grandChildNode2;

      setUp(() {
        grandChildNode1 = TreeNode(id: '1-1');
        grandChildNode2 = TreeNode(id: '1-2');

        root.addChildren([node1, node2]);
        node1.addChildren([grandChildNode1, grandChildNode2]);
      });

      test(
        'Should move the children of node1 to the children of root '
        'When delete is called on node1.',
        () {
          expect(node1.children, [grandChildNode1, grandChildNode2]);
          expect(grandChildNode1.parent, node1);
          expect(grandChildNode2.parent, node1);
          expect(root.children, [node1, node2]);

          node1.delete();

          expect(node1.parent, isNull);
          expect(node1.children, isEmpty);

          expect(root.children, [node2, grandChildNode1, grandChildNode2]);
          expect(grandChildNode1.parent, root);
          expect(grandChildNode2.parent, root);
        },
      );

      test(
        'Should NOT move the children of node1 to the children of root '
        'When delete(recursive: true) is called on node1.',
        () {
          expect(node1.children, [grandChildNode1, grandChildNode2]);
          expect(grandChildNode1.parent, node1);
          expect(grandChildNode2.parent, node1);
          expect(root.children, [node1, node2]);

          node1.delete(recursive: true);

          expect(node1.parent, isNull);
          expect(node1.children, isEmpty);
          expect(node1.descendants.toList(), isEmpty);

          expect(root.children, [node2]);
          expect(grandChildNode1.parent, isNull);
          expect(grandChildNode2.parent, isNull);
        },
      );
    });

    group('clearChildren -', () {
      setUp(() {
        root.addChildren([node1, node2]);
      });
      test(
        'Should clear the children of root and set their parent to null '
        'When clearChildren is called on root.',
        () {
          expect(root.children, [node1, node2]);
          expect(node1.parent, root);
          expect(node2.parent, root);

          root.clearChildren();

          expect(root.children, isEmpty);
          expect(node1.parent, isNull);
          expect(node2.parent, isNull);
        },
      );
    });

    group('find -', () {
      test(
        'Should return null When called on root with id = 3.',
        () {
          root.addChildren([node1, node2]);
          expect(root.find('3'), isNull);
        },
      );
      test(
        'Should return node1, node2 '
        'When called on root with id = 1, id = 2 respectively.',
        () {
          root.addChildren([node1, node2]);
          expect(root.find('1'), node1);
          expect(root.find('2'), node2);
        },
      );
      test(
        'Should return node2 '
        'When called with id = 2 on either root or node1.',
        () {
          root.addChild(node1);
          node1.addChild(node2);
          expect(root.find('2'), node2);
          expect(node1.find('2'), node2);
        },
      );
    });
  });
}
