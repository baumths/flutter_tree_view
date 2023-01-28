import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main/view.dart';
import 'settings/controller.dart';
import 'settings/view.dart';
import 'shared/utils.dart' show checkIsSmallDisplay;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_fancy_tree_view',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: context.select<SettingsController, Color>(
          (controller) => controller.state.color,
        ),
        brightness: context.select<SettingsController, Brightness>(
          (controller) => controller.state.brightness,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        return Directionality(
          textDirection: context.select<SettingsController, TextDirection>(
            (controller) => controller.state.textDirection,
          ),
          child: child!,
        );
      },
      home: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  static final smallDisplayScaffoldKey = GlobalKey<ScaffoldState>();

  /// Necessary when resizing the app so the tree view example inside the
  /// main view doesn't loose its tree states.
  static const mainViewKey = GlobalObjectKey('<MainViewGlobalObjectKey>');

  @override
  Widget build(BuildContext context) {
    if (checkIsSmallDisplay(context)) {
      return Scaffold(
        key: smallDisplayScaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            tooltip: 'Open settings drawer',
            icon: const Icon(Icons.menu),
            onPressed: () => smallDisplayScaffoldKey.currentState?.openDrawer(),
          ),
        ),
        drawer: const SettingsView(),
        body: const MainView(
          key: mainViewKey,
        ),
      );
    }

    return Row(
      children: const [
        SettingsView(),
        VerticalDivider(width: 1),
        Expanded(child: MainView(key: mainViewKey)),
      ],
    );
  }
}
