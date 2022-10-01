import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings.dart';
import '../../../shared/indent_type.dart';
import '_section.dart';

class IndentGuideType extends StatelessWidget {
  const IndentGuideType({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = DefaultTextStyle.of(context) //
        .style
        .apply(
          color: Theme.of(context).colorScheme.primary,
          fontWeightDelta: 2,
        );

    return Section(
      title: 'Indent Guide Type',
      child: Consumer(
        builder: (_, ref, __) {
          final IndentType indentType = ref.watch(indentTypeProvider);

          return ExpansionTile(
            title: Text(
              indentType.label,
              style: titleStyle,
            ),
            children: [
              for (final type in IndentType.allExcept(indentType))
                ListTile(
                  title: Text(type.label),
                  dense: true,
                  onTap: () {
                    ref.read(indentTypeProvider.state).state = type;
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
