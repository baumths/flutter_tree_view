import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/responsive.dart';
import 'sections.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Header(),
        SizedBox(height: 4),
        Expanded(child: Sections()),
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: Colors.black,
      child: Consumer(
        builder: (context, ref, child) {
          final Screen screen = ref.watch(screenProvider);

          return screen.when(
            small: () => InkWell(
              onTap: () => Scaffold.of(context).closeDrawer(),
              child: child,
            ),
            large: () => child!,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (Scaffold.of(context).hasDrawer)
                Tooltip(
                  message: MaterialLocalizations.of(context).closeButtonTooltip,
                  child: const Icon(Icons.close),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
