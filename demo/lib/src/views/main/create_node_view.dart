import 'package:flutter/material.dart';

import '../../providers/tree.dart';

class CreateNodeView extends StatelessWidget {
  const CreateNodeView({super.key, this.parent});

  final DemoNode? parent;

  static Future<T?> showBottomSheetForm<T>(
    BuildContext context, [
    DemoNode? parent,
  ]) async {
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
        child: CreateNodeView(parent: parent),
      ),
    );
  }

  static Future<T?> showDialogForm<T>(
    BuildContext context, [
    DemoNode? parent,
  ]) async {
    return showDialog<T>(
      context: context,
      builder: (_) => Dialog(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CreateNodeView(parent: parent),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelInput(parent: parent),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (parent != null) ...[
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
                    child: Text(
                      parent!.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
              SubmitButton(parent: parent),
            ],
          ),
        ],
      ),
    );
  }
}

class LabelInput extends StatelessWidget {
  const LabelInput({
    super.key,
    this.parent,
  });

  final DemoNode? parent;

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

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, this.parent});

  final DemoNode? parent;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        // TODO
        Navigator.pop(context);
      },
      child: const Text('Create'),
    );
  }
}
