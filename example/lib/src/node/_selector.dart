part of 'tree_node_tile.dart';

class _NodeSelector extends StatelessWidget {
  const _NodeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = TreeNodeScope.of(context).node.id;
    final appController = AppController.of(context);

    return AnimatedBuilder(
      animation: appController,
      builder: (_, __) {
        return Checkbox(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          activeColor: Colors.green.shade600,
          value: appController.isSelected(id),
          onChanged: (_) => appController.toggleSelection(id),
        );
      },
    );
  }
}
