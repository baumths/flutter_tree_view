import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart' show App;
import 'src/examples.dart' show SelectedExampleNotifier;
import 'src/settings/controller.dart' show SettingsController;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => SelectedExampleNotifier()),
      ],
      child: const App(),
    ),
  );
}
