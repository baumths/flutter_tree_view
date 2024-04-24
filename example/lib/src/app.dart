import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'settings/controller.dart';
import 'settings/view.dart';
import 'examples.dart';

class App extends StatelessWidget {
  const App({super.key});

  ThemeData createTheme(Color color, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.primary,
        textColor: colorScheme.onPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (themeColor, themeMode) = context.select(
      (SettingsController controller) => (
        controller.state.color,
        controller.state.themeMode,
      ),
    );

    return MaterialApp(
      title: 'flutter_fancy_tree_view',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      darkTheme: createTheme(themeColor, Brightness.dark),
      theme: createTheme(themeColor, Brightness.light),
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

  /// Necessary when resizing the app so the tree view example inside the
  /// main view doesn't loose its tree states.
  static const examplesViewKey = GlobalObjectKey('<ExamplesViewKey>');

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? appBar;
    Widget? body;
    Widget? drawer;

    if (MediaQuery.of(context).size.width > 720) {
      body = const Row(
        children: [
          SettingsView(),
          VerticalDivider(width: 1),
          Expanded(child: ExamplesView(key: examplesViewKey)),
        ],
      );
    } else {
      appBar = AppBar(
        title: const Text('TreeView Examples'),
        notificationPredicate: (_) => false,
        titleSpacing: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      );
      body = const ExamplesView(key: examplesViewKey);
      drawer = const SettingsView(isDrawer: true);
    }

    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
    );
  }
}
