import 'package:flutter/material.dart';

import 'categories.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, this.isDrawer = false});

  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    late final Widget child = Column(
      children: [
        Header(showCloseButton: isDrawer),
        const Divider(height: 1),
        const Expanded(child: SettingsCategories()),
      ],
    );

    if (isDrawer) {
      return Drawer(child: child);
    }

    return Material(
      child: SizedBox(
        width: 304,
        child: ListTileTheme.merge(
          style: ListTileStyle.drawer,
          child: child,
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key, this.showCloseButton = false});

  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
            const DarkModeButton(),
            if (showCloseButton)
              IconButton(
                tooltip: 'Close settings',
                icon: const Icon(Icons.close),
                onPressed: () => Scaffold.maybeOf(context)?.closeDrawer(),
              ),
          ],
        ),
      ),
    );
  }
}
