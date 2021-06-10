import 'package:flutter/material.dart';

import 'src/app_controller.dart';
import 'src/home_page.dart';

const kDarkBlue = Color(0xFF1565C0);

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppController appController = AppController();

  @override
  void dispose() {
    appController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppControllerScope(
      controller: appController,
      child: MaterialApp(
        title: 'TreeView Example',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: kDarkBlue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          iconTheme: const IconThemeData(color: kDarkBlue),
        ),
        home: FutureBuilder<void>(
          future: appController.init(),
          builder: (_, __) {
            if (appController.isInitialized) {
              return const _Unfocus(child: HomePage());
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _Unfocus extends StatelessWidget {
  const _Unfocus({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: FocusScope.of(context).unfocus,
      child: child,
    );
  }
}
