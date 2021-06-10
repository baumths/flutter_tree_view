part of 'settings_view.dart';

class _Actions extends StatelessWidget {
  const _Actions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Action(
          label: const Text('Add Top Level Node'),
          onPressed: () async => await showAddNodeDialog(context),
        ),
        _Action(
          label: const Text('Expand All'),
          onPressed: AppController.of(context).treeController.expandAll,
        ),
        _Action(
          label: const Text('Collapse All'),
          onPressed: AppController.of(context).treeController.collapseAll,
        ),
        _Action(
          label: const Text('Select All'),
          onPressed: AppController.of(context).selectAll,
        ),
        _Action(
          label: const Text('Deselect All'),
          onPressed: () => AppController.of(context).selectAll(false),
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    Key? key,
    required this.label,
    this.onPressed,
  }) : super(key: key);

  final Widget label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: kDarkBlue,
        backgroundColor: const Color(0x331565c0),
        padding: const EdgeInsets.all(20),
        side: const BorderSide(color: kDarkBlue),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      onPressed: onPressed,
      child: label,
    );
  }
}
