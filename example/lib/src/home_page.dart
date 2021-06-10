import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import 'settings/settings_view.dart';
import 'custom_tree_view.dart';

const String url = '''
https://github.com/mbaumgartenbr/flutter_tree_view/tree/main/example
''';

void _launchExampleSourceCode() {
  canLaunch(url).then((bool canLaunch) {
    if (canLaunch) launch(url);
  });
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _isSmallDisplay = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: const _ResponsiveBody(),
      endDrawer: const Drawer(child: SettingsView()),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('TreeView Example'),
        leading: const IconButton(
          tooltip: 'SOURCE CODE',
          icon: Icon(Icons.open_in_new_rounded),
          onPressed: _launchExampleSourceCode,
        ),
        actions: _isSmallDisplay ? null : const [SizedBox()],
      ),
    );
  }
}

class _ResponsiveBody extends StatelessWidget {
  const _ResponsiveBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      return const CustomTreeView();
    }
    return Row(
      children: const [
        Flexible(flex: 2, child: CustomTreeView()),
        VerticalDivider(
          width: 2,
          thickness: 2,
          color: Colors.black26,
        ),
        Expanded(child: SettingsView()),
      ],
    );
  }
}
