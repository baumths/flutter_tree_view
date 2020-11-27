part of 'home_page.dart';

class _ToggleNodesFAB extends StatefulWidget {
  const _ToggleNodesFAB({
    required this.controller,
    Key? key,
  }) : super(key: key);

  final TreeViewController controller;

  @override
  __ToggleNodesFABState createState() => __ToggleNodesFABState();
}

class __ToggleNodesFABState extends State<_ToggleNodesFAB> {
  bool allNodesExpanded = false;

  late final TreeViewController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    final _color = allNodesExpanded ? Colors.red : Colors.green;
    final _icon = allNodesExpanded ? Icons.unfold_less : Icons.unfold_more;
    final _text = allNodesExpanded ? 'COLLAPSE ALL' : 'EXPAND ALL';
    return FloatingActionButton.extended(
      icon: Icon(_icon),
      backgroundColor: _color,
      label: Text(_text),
      onPressed: () {
        allNodesExpanded ? controller.collapseAll() : controller.expandAll();
        setState(() {
          allNodesExpanded = !allNodesExpanded;
        });
      },
    );
  }
}

void showSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 1),
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
}
