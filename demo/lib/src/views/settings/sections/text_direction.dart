import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '_section.dart';

extension on TextDirection {
  String get label {
    switch (this) {
      case TextDirection.rtl:
        return 'Right to Left';
      case TextDirection.ltr:
        return 'Left to Right ';
    }
  }

  TextDirection get opposite {
    switch (this) {
      case TextDirection.rtl:
        return TextDirection.ltr;
      case TextDirection.ltr:
        return TextDirection.rtl;
    }
  }
}

class Direction extends ConsumerWidget {
  const Direction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = DefaultTextStyle.of(context) //
        .style
        .apply(
          color: Theme.of(context).colorScheme.primary,
          fontWeightDelta: 2,
        );

    return Section(
      title: 'Text Direction',
      child: ListTile(
        title: Consumer(builder: (_, ref, __) {
          final TextDirection textDirection = ref.watch(textDirectionProvider);

          return Text(
            textDirection.label,
            style: titleStyle,
          );
        }),
        trailing: const Icon(Icons.swap_horiz),
        onTap: () => ref
            .read(textDirectionProvider.state)
            .update((textDirection) => textDirection.opposite),
      ),
    );
  }
}
