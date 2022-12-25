import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/responsive.dart' show Screen;
import '../../tree.dart';

final _labelInputState = StateProvider.autoDispose<String>((ref) => '');

class CreateNodeView extends ConsumerWidget {
  const CreateNodeView({super.key});

  static Future<DemoNode?> show(BuildContext context, Screen screen) {
    return screen.when<Future<DemoNode?>>(
      small: () => CreateNodeView.showBottomSheetForm(context),
      large: () => CreateNodeView.showDialogForm(context),
    );
  }

  static Future<DemoNode?> showBottomSheetForm(BuildContext context) async {
    return showModalBottomSheet<DemoNode>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: const CreateNodeView(),
      ),
    );
  }

  static Future<DemoNode?> showDialogForm(BuildContext context) async {
    return showDialog<DemoNode>(
      context: context,
      builder: (_) => const Dialog(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CreateNodeView(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_labelInputState);

    void submit() {
      String label = ref.read(_labelInputState);

      if (label.trim().isEmpty) {
        label = 'New Node';
      }

      Navigator.pop(
        context,
        DemoNode(label: label),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            autofocus: true,
            onSubmitted: (_) => submit(),
            onChanged: (String value) {
              ref.read(_labelInputState.state).state = value;
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Label',
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: submit,
              child: const Text('Create'),
            ),
          ),
        ],
      ),
    );
  }
}
