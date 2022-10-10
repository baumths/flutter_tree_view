import 'package:flutter/material.dart';

import 'settings/view.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox(
        width: 304,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(10, 0),
                blurRadius: 10,
                spreadRadius: -10,
              ),
              BoxShadow(
                color: Colors.black26,
                offset: Offset(-10, 0),
                blurRadius: 10,
                spreadRadius: -10,
              ),
            ],
          ),
          child: const SettingsView(),
        ),
      ),
    );
  }
}

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(child: SettingsView());
  }
}
