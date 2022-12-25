part of 'tile.dart';

class NodeScope extends InheritedWidget {
  const NodeScope({
    super.key,
    required super.child,
    required this.node,
  });

  final DemoNode node;

  static DemoNode of(BuildContext context) {
    final DemoNode? node = context //
        .dependOnInheritedWidgetOfExactType<NodeScope>()
        ?.node;
    assert(node != null, 'No NodeScope in context.');
    return node!;
  }

  @override
  bool updateShouldNotify(NodeScope oldWidget) => true;
}
