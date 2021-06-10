import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import '../app_controller.dart';

const _kDarkBlue = Color(0xFF1565C0);

Future<void> showAddNodeDialog(BuildContext context, [TreeNode? node]) async {
  final appController = AppController.of(context);
  final treeController = appController.treeController;

  final _node = node ?? appController.rootNode;

  final _isSmallDisplay = MediaQuery.of(context).size.width < 600;

  FormData? formData;

  if (_isSmallDisplay) {
    formData = await showModalBottomSheet<FormData>(
      enableDrag: false,
      context: context,
      builder: (_) => AddNodeDialog(parentLabel: _node.id),
    );
  } else {
    formData = await showDialog<FormData>(
      context: context,
      builder: (_) => Dialog(
        child: AddNodeDialog(parentLabel: _node.id),
      ),
    );
  }
  if (formData != null) {
    _node.addChild(TreeNode(id: formData.id, label: formData.label));

    if (_node.isRoot) {
      treeController.reset(keepExpandedNodes: true);
      //
    } else if (treeController.isExpanded(_node.id)) {
      //
      treeController.refreshNode(_node);
    } else {
      treeController.expandNode(_node);
    }
  }
}

class AddNodeDialog extends StatefulWidget {
  const AddNodeDialog({Key? key, required this.parentLabel}) : super(key: key);

  final String parentLabel;

  @override
  _AddNodeDialogState createState() => _AddNodeDialogState();
}

class _AddNodeDialogState extends State<AddNodeDialog> {
  static const TextStyle textFieldLabelStyle = TextStyle(
    color: Colors.blueGrey,
    fontWeight: FontWeight.bold,
  );

  late final TextEditingController idController = TextEditingController();
  late final TextEditingController labelController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      width: 400,
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'Adding a new child to:  '),
                  TextSpan(
                    text: widget.parentLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
              ),
            ),
          ),
          const Divider(
            color: Colors.black26,
            height: 10,
            thickness: 2,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 36, top: 8),
            child: Text('ID', style: textFieldLabelStyle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _TextField(
              autofocus: true,
              controller: idController,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 36, top: 8),
            child: Text('LABEL', style: textFieldLabelStyle),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: _TextField(
              controller: labelController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ButtonBar(
              children: [
                ExcludeFocus(
                  excluding: true,
                  child: IconButton(
                    tooltip: 'CANCEL',
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.close_rounded, color: Colors.red),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: _kDarkBlue),
                  onPressed: _submitted,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          if (mediaQuery.size.width < 600)
            SizedBox(height: mediaQuery.viewInsets.bottom),
        ],
      ),
    );
  }

  void _submitted() {
    final id = idController.text.trim();
    final label = labelController.text.trim();

    final formData = FormData.create(
      id: id.isEmpty ? null : id,
      label: label.isEmpty ? null : label,
    );

    Navigator.of(context).pop(formData);
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    Key? key,
    required this.controller,
    this.autofocus = false,
  }) : super(key: key);

  static const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderSide: BorderSide(color: _kDarkBlue),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  final bool autofocus;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      cursorColor: _kDarkBlue,
      style: const TextStyle(
        color: _kDarkBlue,
        fontWeight: FontWeight.w600,
      ),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(16, 2, 16, 2),
        focusColor: _kDarkBlue,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        border: InputBorder.none,
        fillColor: Color(0x551565C0),
        filled: true,
      ),
    );
  }
}

class FormData {
  static int _id = 0;

  FormData._({required this.id, required this.label});

  static FormData create({String? id, String? label}) {
    return FormData._(
      id: id ?? '${_id++}',
      label: label ?? 'Added Node',
    );
  }

  final String id;
  final String label;
}
