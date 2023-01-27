import 'package:flutter/material.dart';

import '../shared/utils.dart' show checkIsSmallDisplay;
import 'categories.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    late final Widget child = Column(
      children: const [
        Header(),
        Divider(height: 1),
        Expanded(child: SettingsCategories()),
      ],
    );

    if (checkIsSmallDisplay(context)) {
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
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: 16, end: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
            const DarkModeButton(),
            if (checkIsSmallDisplay(context))
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
