import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:flutter_test/flutter_test.dart';

Iterable<T> emptyChildrenProvider<T>(T _) => const Iterable.empty();

class TestTreeController<T extends Object> extends TreeController<T> {
  TestTreeController({
    super.roots = const [],
    ChildrenProvider<T>? childrenProvider,
    super.parentProvider,
  }) : super(childrenProvider: childrenProvider ?? emptyChildrenProvider);

  int defaultDescendConditionCallCount = 0;
  int notifyListenersCallCount = 0;

  @override
  bool defaultDescendCondition(TreeEntry<T> entry) {
    ++defaultDescendConditionCallCount;
    return super.defaultDescendCondition(entry);
  }

  @override
  void notifyListeners() {
    ++notifyListenersCallCount;
    super.notifyListeners();
  }
}

bool visitRootsOnly(TreeEntry<String> entry) => false;
bool visitAllNodes(TreeEntry<String> entry) => true;

class TestTree {
  static const String root = '0';

  TestTree.depthFirst()
      : flatTree = List<String>.unmodifiable([
          '1',
          '1.1',
          '1.1.1',
          '1.1.2',
          '1.2',
          '1.2.1',
          '1.2.2',
          '2',
          '2.1',
          '2.1.1',
          '2.1.1.1',
          '2.1.1.1.1',
          '3',
        ]);

  TestTree.breadthFirst()
      : flatTree = List<String>.unmodifiable([
          '1',
          '2',
          '3',
          '1.1',
          '1.2',
          '2.1',
          '1.1.1',
          '1.1.2',
          '1.2.1',
          '1.2.2',
          '2.1.1',
          '2.1.1.1',
          '2.1.1.1.1',
        ]);

  final childrenOf = Map<String, List<String>>.unmodifiable({
    root: ['1', '2', '3'],
    '1': ['1.1', '1.2'],
    '1.1': ['1.1.1', '1.1.2'],
    '1.2': ['1.2.1', '1.2.2'],
    '2': ['2.1'],
    '2.1': ['2.1.1'],
    '2.1.1': ['2.1.1.1'],
    '2.1.1.1': ['2.1.1.1.1'],
  });

  final parentOf = Map<String, String>.unmodifiable({
    '1.1': '1',
    '1.1.1': '1.1',
    '1.1.2': '1.1',
    '1.2': '1',
    '1.2.1': '1.2',
    '1.2.2': '1.2',
    '2.1': '2',
    '2.1.1': '2.1',
    '2.1.1.1': '2.1.1',
    '2.1.1.1.1': '2.1.1.1',
  });

  final List<String> flatTree;

  int get totalNodeCount => flatTree.length;

  Iterable<String> childrenProvider(String node) {
    return childrenOf[node] ?? const Iterable.empty();
  }

  String? parentProvider(String node) => parentOf[node];

  Iterable<String> get roots => childrenProvider(root);

  int getLevel(String node) => node.split('.').length - 1;

  bool isLastChild(String node) {
    final siblings = childrenProvider(parentOf[node] ?? root);
    return siblings.isEmpty || node == siblings.last;
  }

  TestTreeController<String> createController() {
    return TestTreeController<String>(
      roots: roots,
      childrenProvider: childrenProvider,
      parentProvider: parentProvider,
    );
  }
}

void main() {
  group('TreeController', () {
    test('testing properties like *CallCount always start at 0', () {
      final controller = TestTreeController();
      expect(controller.notifyListenersCallCount, equals(0));
      expect(controller.defaultDescendConditionCallCount, equals(0));
    });

    test('properly sets root nodes', () {
      final controller = TestTreeController(roots: const [1, 2, 3]);

      expect(controller.roots, equals(const [1, 2, 3]));
      controller.roots = const [];
      expect(controller.roots, equals(const []));
    });

    test('properly calls notifyListeners() when updating roots', () {
      const roots = [1, 2, 3];
      final controller = TestTreeController(roots: roots);

      controller.roots = roots;
      expect(controller.notifyListenersCallCount, equals(0));

      controller.roots = const [];
      expect(controller.notifyListenersCallCount, equals(1));
    });

    test(
      'setExpansionState() properly updates the expansion state of nodes',
      () {
        const roots = [1, 2, 3];
        final controller = TestTreeController(roots: roots);

        expect(controller.getExpansionState(1), isFalse);
        controller.setExpansionState(1, true);
        expect(controller.getExpansionState(1), isTrue);
        controller.setExpansionState(1, false);
        expect(controller.getExpansionState(1), isFalse);
      },
    );

    test('setExpansionState() must not call notifyListeners()', () {
      final controller = TestTreeController();

      for (int node = 0; node < 1000; ++node) {
        controller.setExpansionState(node, true);
        controller.setExpansionState(node, false);
      }
      expect(controller.notifyListenersCallCount, equals(0));
    });

    test('getExpansionState() returns the correct value for a given node', () {
      const roots = [1, 2, 3];
      final controller = TestTreeController(roots: roots);

      for (final root in roots) {
        expect(controller.getExpansionState(root), isFalse);
      }

      controller.setExpansionState(2, true);

      expect(controller.getExpansionState(1), isFalse);
      expect(controller.getExpansionState(2), isTrue);
      expect(controller.getExpansionState(3), isFalse);
    });

    group('toggleExpansion()', () {
      test('properly flips the expansion state of a node', () {
        final controller = TestTreeController();
        expect(controller.getExpansionState(1), isFalse);

        controller.toggleExpansion(1);
        expect(controller.getExpansionState(1), isTrue);

        controller.toggleExpansion(1);
        expect(controller.getExpansionState(1), isFalse);
      });

      test('calls notifyListeners() once', () {
        final controller = TestTreeController();
        controller.toggleExpansion(1);
        expect(controller.notifyListenersCallCount, equals(1));
      });
    });

    group('expand()', () {
      late TestTreeController<int> controller;

      setUp(() {
        controller = TestTreeController();
      });

      test('expands a node when it is collapsed', () {
        expect(controller.getExpansionState(1), isFalse);
        controller.expand(1);
        expect(controller.getExpansionState(1), isTrue);
      });

      test('does nothing if node is already expanded', () {
        controller.setExpansionState(1, true);
        expect(controller.getExpansionState(1), isTrue);

        controller.expand(1);
        expect(controller.getExpansionState(1), isTrue);
        expect(controller.notifyListenersCallCount, equals(0));
      });

      test('properly calls notifyListeners()', () {
        final controller = TestTreeController();

        controller.expand(1);
        expect(controller.notifyListenersCallCount, equals(1));

        controller.expand(1);
        expect(controller.notifyListenersCallCount, equals(1));
      });
    });

    group('collapse()', () {
      late TestTreeController<int> controller;

      setUp(() {
        controller = TestTreeController();
      });

      test('collapses a node when it is expanded', () {
        controller.setExpansionState(1, true);
        expect(controller.getExpansionState(1), isTrue);

        controller.collapse(1);
        expect(controller.getExpansionState(1), isFalse);
      });

      test('does nothing if node is already expanded', () {
        expect(controller.getExpansionState(1), isFalse);

        controller.collapse(1);
        expect(controller.getExpansionState(1), isFalse);
        expect(controller.notifyListenersCallCount, equals(0));
      });

      test('properly calls notifyListeners()', () {
        expect(controller.getExpansionState(1), isFalse);

        controller.collapse(1);
        expect(controller.notifyListenersCallCount, equals(0));

        controller.setExpansionState(1, true);
        controller.collapse(1);
        expect(controller.notifyListenersCallCount, equals(1));
      });
    });

    group('(expand/collapse)Cascading()', () {
      const root = 1;
      // parent -> child: 1 -> 2 -> 3 -> ... -> 50
      final flatTree = List.generate(50, (index) => index + 1);
      // 1: 2, 2: 3, 3: 4, ..., 49: 50
      final childOf = {for (final node in flatTree.sublist(1)) node - 1: node};

      late TestTreeController<int> controller;

      setUp(() {
        controller = TestTreeController(
          roots: const [root],
          childrenProvider: (int node) {
            if (childOf.containsKey(node)) return [childOf[node]!];
            return const Iterable.empty();
          },
        );
      });

      test('does nothing when provided empty iterables', () {
        final controller = TestTreeController(roots: const [root]);

        controller.expandCascading(const Iterable.empty());
        expect(controller.getExpansionState(root), isFalse);
        expect(controller.notifyListenersCallCount, equals(0));

        controller.setExpansionState(root, true);
        controller.collapseCascading(const Iterable.empty());
        expect(controller.getExpansionState(root), isTrue);
        expect(controller.notifyListenersCallCount, equals(0));
      });

      test('properly expands and collapses subtrees', () {
        for (final node in flatTree) {
          expect(controller.getExpansionState(node), isFalse);
        }

        controller.expandCascading(const [root]);
        for (final node in flatTree) {
          expect(controller.getExpansionState(node), isTrue);
        }

        controller.collapseCascading(const [root]);
        for (final node in flatTree) {
          expect(controller.getExpansionState(node), isFalse);
        }
      });
    });

    test('expandAll() properly expands every node', () {
      final tree = TestTree.breadthFirst();
      final controller = TreeController<String>(
        roots: tree.roots,
        childrenProvider: tree.childrenProvider,
      );

      controller.breadthFirstSearch(onTraverse: (String node) {
        expect(controller.getExpansionState(node), isFalse);
      });

      controller.expandAll();

      controller.breadthFirstSearch(onTraverse: (String node) {
        expect(controller.getExpansionState(node), isTrue);
      });
    });

    test('collapseAll() properly collapses every node', () {
      final tree = TestTree.breadthFirst();
      final controller = TreeController<String>(
        roots: tree.roots,
        childrenProvider: tree.childrenProvider,
      )..expandAll();

      controller.breadthFirstSearch(onTraverse: (String node) {
        expect(controller.getExpansionState(node), isTrue);
      });

      controller.collapseAll();

      controller.breadthFirstSearch(onTraverse: (String node) {
        expect(controller.getExpansionState(node), isFalse);
      });
    });

    group('expandAncestors()', () {
      const root = 1;
      const target = 7;
      const ancestors = [1, 2, 3, 4, 5, 6];
      const parentOf = {target: 6, 6: 5, 5: 4, 4: 3, 3: 2, 2: 1};

      late TestTreeController<int> controller;

      setUp(() {
        controller = TestTreeController(
          roots: const [root],
          parentProvider: (int node) => parentOf[node],
        );
      });

      test('expands all ancestors of a node', () {
        for (final node in ancestors) {
          expect(controller.getExpansionState(node), isFalse);
        }

        controller.expandAncestors(target);

        for (final node in ancestors) {
          expect(controller.getExpansionState(node), isTrue);
        }
      });

      test('does not expand the node passed to it', () {
        expect(controller.getExpansionState(target), isFalse);

        controller.expandAncestors(target);
        for (final node in ancestors) {
          expect(controller.getExpansionState(node), isTrue);
        }

        expect(controller.getExpansionState(target), isFalse);
      });

      test('properly calls notifyListeners()', () {
        controller.expandAncestors(root);
        expect(controller.notifyListenersCallCount, equals(0));

        controller.expandAncestors(target);
        expect(controller.notifyListenersCallCount, equals(1));
      });
    });

    test('areAllRootsExpanded', () {
      final controller = TestTreeController(roots: const [1, 2, 3]);
      expect(controller.areAllRootsExpanded, isFalse);

      for (final root in controller.roots) {
        expect(controller.areAllRootsExpanded, isFalse);
        controller.setExpansionState(root, true);
      }

      expect(controller.areAllRootsExpanded, isTrue);

      for (final root in controller.roots) {
        controller.setExpansionState(root, false);
      }

      expect(controller.areAllRootsExpanded, isFalse);
    });

    test('areAllRootsCollapsed', () {
      final controller = TestTreeController(roots: const [1, 2, 3]);
      expect(controller.areAllRootsCollapsed, isTrue);

      controller.setExpansionState(2, true);
      expect(controller.areAllRootsCollapsed, isFalse);

      controller.setExpansionState(2, false);
      expect(controller.areAllRootsCollapsed, isTrue);

      for (final root in controller.roots) {
        controller.setExpansionState(root, true);
      }

      expect(controller.areAllRootsCollapsed, isFalse);
    });

    group('isTreeExpanded', () {
      late TestTree tree;
      late TestTreeController<String> controller;

      setUp(() {
        tree = TestTree.breadthFirst();
        controller = tree.createController();
      });

      test('only returns true when all tree nodes are expanded', () {
        controller.collapseAll();
        expect(controller.isTreeExpanded, isFalse);

        controller.expand('3');
        expect(controller.isTreeExpanded, isFalse);

        controller.expandCascading(const ['2']);
        expect(controller.isTreeExpanded, isFalse);

        controller.expand('1');
        expect(
          controller.isTreeExpanded,
          isFalse,
          reason: 'All root nodes have been expanded, but there are still '
              'some collapsed nodes in the subtree of node "1"',
        );

        controller.expandAll();
        expect(controller.isTreeExpanded, isTrue);
      });
    });

    group('isTreeCollapsed', () {
      late TestTree tree;
      late TestTreeController<String> controller;

      setUp(() {
        tree = TestTree.breadthFirst();
        controller = tree.createController();
      });

      test('only returns true when all tree nodes are collapsed', () {
        controller.expandAll();
        expect(controller.isTreeCollapsed, isFalse);

        controller.collapse('3');
        expect(controller.isTreeCollapsed, isFalse);

        controller.collapseCascading(const ['2']);
        expect(controller.isTreeCollapsed, isFalse);

        controller.collapse('1');
        expect(
          controller.isTreeCollapsed,
          isFalse,
          reason: 'All root nodes have been collapsed, but there are still '
              'some expanded nodes in the subtree of node "1"',
        );

        controller.collapseAll();
        expect(controller.isTreeCollapsed, isTrue);
      });
    });

    group('breadthFirstSearch()', () {
      late TestTree tree;
      late TestTreeController<String> controller;

      setUp(() {
        tree = TestTree.breadthFirst();
        controller = tree.createController();
      });

      test('uses roots when startingNodes is not provided', () {
        final visitedNodes = <String>[];

        controller.breadthFirstSearch(
          startingNodes: null,
          onTraverse: visitedNodes.add,
        );

        expect(visitedNodes, containsAll(controller.roots));
      });

      test('uses startingNodes when provided', () {
        const flatSubtree = <String>[
          '1',
          '1.1',
          '1.2',
          '1.1.1',
          '1.1.2',
          '1.2.1',
          '1.2.2',
        ];
        final visitedNodes = <String>[];

        controller.breadthFirstSearch(
          startingNodes: ['1'],
          onTraverse: (String node) {
            expect(node, startsWith('1'));
            visitedNodes.add(node);
          },
        );

        expect(visitedNodes, isNot(containsAll(const ['2', '3'])));

        expect(visitedNodes.length, equals(flatSubtree.length));
        expect(visitedNodes, equals(flatSubtree));
      });

      test('traverses the tree in the right order', () {
        final flatTree = List.of(tree.flatTree);

        controller.breadthFirstSearch(
          onTraverse: (String node) {
            expect(node, equals(flatTree.removeAt(0)));
          },
        );

        expect(flatTree, isEmpty);
      });

      test('calls onTraverse for every visited node', () {
        // Traverse all nodes
        int index = 0;
        controller.breadthFirstSearch(
          onTraverse: (String node) {
            expect(node, equals(tree.flatTree[index]));
            index++;
          },
        );

        // Traverse expanded nodes only
        for (final root in tree.roots) {
          controller.setExpansionState(root, true);
        }

        const flatTree = ['1', '2', '3', '1.1', '1.2', '2.1'];
        final visitedNodes = <String>[];

        controller.breadthFirstSearch(
          descendCondition: controller.getExpansionState,
          onTraverse: visitedNodes.add,
        );

        expect(visitedNodes.length, equals(flatTree.length));
        for (int index = 0; index < flatTree.length; ++index) {
          expect(visitedNodes[index], equals(flatTree[index]));
        }
      });

      test('calls descendCondition for every visited node', () {
        int visitedNodesCount = 0;

        controller.breadthFirstSearch(
          descendCondition: (_) {
            visitedNodesCount++;
            return true; // visit all nodes
          },
        );

        expect(visitedNodesCount, equals(tree.totalNodeCount));
      });

      test('respects descendCondition', () {
        final result = ['1', '2', '3', '2.1', '2.1.1', '2.1.1.1', '2.1.1.1.1'];

        controller.breadthFirstSearch(
          descendCondition: (String node) => node.startsWith('2'),
          onTraverse: (String node) {
            expect(node, equals(result.removeAt(0)));
          },
        );

        expect(result, isEmpty);
      });

      test(
        'does not call descendCondition for the node matched by returnCondition',
        () {
          const target = '2.1';

          controller.breadthFirstSearch(
            returnCondition: (String node) => node == target,
            descendCondition: (String node) {
              expect(node, isNot(equals(target)));
              return true;
            },
          );
        },
      );

      test('respects returnCondition', () {
        final visitedNodes = <String>[];

        controller.breadthFirstSearch(
          returnCondition: (String node) => node == '3',
          onTraverse: visitedNodes.add,
        );

        expect(visitedNodes.length, equals(3));
        expect(visitedNodes, equals(controller.roots));
      });

      test('onTraverse is called for the node matched in returnCondition', () {
        const target = '1';
        final visitedNodes = <String>[];

        controller.breadthFirstSearch(
          onTraverse: visitedNodes.add,
          returnCondition: (String node) => node == target,
        );

        expect(visitedNodes, contains(target));
      });

      test('returns the node that matches the returnCondition', () {
        const target = '2.1.1.1';

        final String? result = controller.breadthFirstSearch(
          returnCondition: (String node) => node == target,
        );

        expect(result, isNotNull);
        expect(result, equals(target));
      });

      test('returns null if the returnCondition is never met', () {
        final String? result = controller.breadthFirstSearch(
          returnCondition: (String node) => node == 'not a node',
        );

        expect(result, isNull);
      });

      test('completes the traversal if returnCondition is not provided', () {
        int visitedNodesCount = 0;
        controller.breadthFirstSearch(onTraverse: (_) => visitedNodesCount++);
        expect(visitedNodesCount, equals(tree.totalNodeCount));
      });

      test('stops the traversal when returnCondition is met', () {
        const amountOfNodesToTraverse = 3;

        int nodeCount = 0;
        final visitedNodes = <String>[];

        controller.breadthFirstSearch(
          returnCondition: (_) => nodeCount == amountOfNodesToTraverse,
          onTraverse: (String node) {
            nodeCount++;
            visitedNodes.add(node);
          },
        );

        expect(nodeCount, equals(amountOfNodesToTraverse));
        expect(visitedNodes.length, equals(amountOfNodesToTraverse));
        expect(visitedNodes, equals(controller.roots));
      });
    });

    group('depthFirstTraversal()', () {
      late TestTree tree;
      late TestTreeController<String> controller;

      setUp(() {
        tree = TestTree.depthFirst();
        controller = tree.createController();
      });

      test('traverses the tree in the right order', () {
        final flatTree = List.of(tree.flatTree);

        controller.depthFirstTraversal(
          descendCondition: visitAllNodes,
          onTraverse: (TreeEntry<String> entry) {
            expect(entry.node, equals(flatTree.removeAt(0)));
          },
        );

        expect(flatTree, isEmpty);
      });

      test('calls onTraverse for every visited node', () {
        for (final root in tree.roots) {
          controller.setExpansionState(root, true);
        }

        const flatTree = ['1', '1.1', '1.2', '2', '2.1', '3'];
        final visitedNodes = <String>[];

        controller.depthFirstTraversal(
          onTraverse: (TreeEntry<String> entry) {
            visitedNodes.add(entry.node);
          },
        );

        expect(visitedNodes.length, equals(flatTree.length));
        for (int index = 0; index < flatTree.length; ++index) {
          expect(visitedNodes[index], equals(flatTree[index]));
        }
      });

      test('calls descendCondition for every visited node', () {
        int visitedNodesCount = 0;

        controller.depthFirstTraversal(
          onTraverse: (_) {},
          descendCondition: (_) {
            visitedNodesCount++;
            return true; // visit all nodes
          },
        );

        expect(visitedNodesCount, equals(tree.totalNodeCount));
      });

      test('respects descendCondition', () {
        final result = ['1', '2', '2.1', '2.1.1', '2.1.1.1', '2.1.1.1.1', '3'];

        controller.depthFirstTraversal(
          descendCondition: (TreeEntry<String> entry) {
            return entry.node.startsWith('2');
          },
          onTraverse: (TreeEntry<String> entry) {
            expect(entry.node, equals(result.removeAt(0)));
          },
        );

        expect(result, isEmpty);
      });

      test(
        'calls defaultDescendCondition() when descendCondition is not provided',
        () {
          expect(controller.defaultDescendConditionCallCount, equals(0));
          controller.expandCascading(tree.roots);

          controller.depthFirstTraversal(
            descendCondition: null,
            onTraverse: (_) {},
          );

          expect(
            controller.defaultDescendConditionCallCount,
            equals(tree.totalNodeCount),
          );
        },
      );

      test('attributes the correct index for each TreeEntry', () {
        final flatTree = <TreeEntry<String>>[];

        controller.depthFirstTraversal(
          descendCondition: visitAllNodes,
          onTraverse: flatTree.add,
        );

        for (int index = 0; index < tree.totalNodeCount; ++index) {
          final entry = flatTree[index];
          expect(entry.index, equals(index));
        }
      });

      group('created TreeEntry', () {
        test('has its parent set to null only when it is a root entry', () {
          controller.depthFirstTraversal(
            descendCondition: visitAllNodes,
            onTraverse: (TreeEntry<String> entry) {
              if (tree.roots.contains(entry.node)) {
                expect(entry.parent, isNull);
              } else {
                expect(entry.parent, isNotNull);
              }
            },
          );
        });

        test('references the correct parent node', () {
          final flatTree = <TreeEntry<String>>[];

          controller.depthFirstTraversal(
            descendCondition: visitAllNodes,
            onTraverse: flatTree.add,
          );

          for (final entry in flatTree) {
            final String? maybeParent = entry.parent?.node;
            final String? actualParent = tree.parentOf[entry.node];

            if (maybeParent == null) {
              expect(actualParent, isNull);
              expect(tree.roots, contains(entry.node));
            } else {
              expect(actualParent, isNotNull);
              expect(maybeParent, equals(actualParent));
            }
          }
        });

        test('receives the current expansion state of its node', () {
          void verifyAllNodes() {
            controller.depthFirstTraversal(
              descendCondition: visitAllNodes,
              onTraverse: (TreeEntry<String> entry) {
                expect(
                  entry.isExpanded,
                  equals(controller.getExpansionState(entry.node)),
                );
              },
            );
          }

          verifyAllNodes();
          controller.expandCascading(tree.roots);
          verifyAllNodes();
          controller.collapseCascading(const ['2']);
          verifyAllNodes();
        });

        test('receives the correct value for level', () {
          controller.depthFirstTraversal(
            descendCondition: visitAllNodes,
            onTraverse: (TreeEntry<String> entry) {
              expect(entry.level, equals(tree.getLevel(entry.node)));
            },
          );
        });

        test('receives the correct value for hasChildren', () {
          controller.depthFirstTraversal(
            descendCondition: visitAllNodes,
            onTraverse: (TreeEntry<String> entry) {
              expect(
                entry.hasChildren,
                equals(tree.childrenProvider(entry.node).isNotEmpty),
              );
            },
          );
        });

        test('receives the correct value for hasNextSibling', () {
          final flatTree = <TreeEntry<String>>[];

          controller.depthFirstTraversal(
            descendCondition: visitAllNodes,
            onTraverse: flatTree.add,
          );

          for (final entry in flatTree) {
            final hasNextSibling = !tree.isLastChild(entry.node);
            expect(entry.hasNextSibling, equals(hasNextSibling));
          }
        });
      });

      group('rootEntry', () {
        late TreeEntry<String> rootEntry;
        const rootEntryLevel = 2;

        setUp(() {
          controller.depthFirstTraversal(
            descendCondition: visitAllNodes,
            onTraverse: (TreeEntry<String> entry) {
              if (entry.node == '2.1.1') {
                rootEntry = entry;
              }
            },
          );
        });

        test('is not visited', () {
          controller.depthFirstTraversal(
            rootEntry: rootEntry,
            descendCondition: visitAllNodes,
            onTraverse: (TreeEntry<String> entry) {
              expect(entry.node, isNot(equals(rootEntry.node)));
            },
          );
        });

        test('only visits its own subtree', () {
          const subtree = ['2.1.1.1', '2.1.1.1.1'];
          const unreachable = [
            '1',
            '1.1',
            '1.1.1',
            '1.1.2',
            '1.2',
            '2',
            '2.1',
            '1.2.1',
            '1.2.2',
            '3'
          ];
          int visitedNodesCount = 0;

          controller.depthFirstTraversal(
            rootEntry: rootEntry,
            descendCondition: visitAllNodes,
            onTraverse: (TreeEntry<String> entry) {
              expect(entry.node, startsWith('2.1.1'));
              expect(subtree.contains(entry.node), isTrue);
              expect(unreachable.contains(entry.node), isFalse);
              ++visitedNodesCount;
            },
          );
          expect(visitedNodesCount, equals(subtree.length));
        });

        test('is used as the parent of root nodes', () {
          controller.depthFirstTraversal(
            rootEntry: rootEntry,
            descendCondition: visitRootsOnly,
            onTraverse: (TreeEntry<String> entry) {
              expect(entry.parent, isNotNull);
              expect(entry.parent!.node, equals(rootEntry.node));
            },
          );
        });

        test('has its level propagated to the new entries', () {
          controller.depthFirstTraversal(
            rootEntry: rootEntry,
            descendCondition: visitRootsOnly,
            onTraverse: (TreeEntry<String> entry) {
              expect(entry.level, greaterThan(rootEntryLevel));
              expect(entry.level - 1, equals(rootEntry.level));
            },
          );
        });
      });
    });
  });
}
