import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

class DemoFolderButton extends StatelessWidget {
  const DemoFolderButton({
    super.key,
    this.isLoading = false,
    this.isLeaf = false,
    this.isOpen = false,
    this.color,
    this.onTap,
  });

  final bool isLoading;
  final bool isLeaf;
  final bool isOpen;

  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: color,
            ),
          ),
        ),
      );
    }

    if (isLeaf) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(Icons.article_outlined, color: color),
      );
    }

    return FolderButton(
      isOpen: isOpen,
      color: color,
      onPressed: onTap,
    );
  }
}
