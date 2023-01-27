import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/main/controller.dart';
import 'src/settings/controller.dart';

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
