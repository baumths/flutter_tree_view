import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart' show App;
import 'src/examples.dart' show SelectedExampleNotifier;
import 'src/settings/controller.dart' show SettingsController;

Future<void> main() async {
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController(prefs)),
        ChangeNotifierProvider(create: (_) => SelectedExampleNotifier(prefs)),
      ],
      child: const App(),
    ),
  );
}
