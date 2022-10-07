import 'package:flutter/material.dart';

import '../../providers/responsive.dart' show Screen;

class CreateNodeView extends StatelessWidget {
  const CreateNodeView({super.key});

  static Future<T?> show<T>(BuildContext context, Screen screen) {
    return screen.when<Future<T?>>(
      small: () => CreateNodeView.showBottomSheetForm<T>(context),
      large: () => CreateNodeView.showDialogForm<T>(context),
    );
  }

  static Future<T?> showBottomSheetForm<T>(BuildContext context) async {
    return showModalBottomSheet<T>(
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

  static Future<T?> showDialogForm<T>(BuildContext context) async {
    return showDialog<T>(
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LabelInput(),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              child: const Text('Create'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class LabelInput extends StatelessWidget {
  const LabelInput({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      autofocus: true,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Label',
      ),
    );
  }
}
