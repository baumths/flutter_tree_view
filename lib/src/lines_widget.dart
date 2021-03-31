import 'internal.dart';

/// Widget responsible for indenting nodes and drawing lines (if enabled).
class LinesWidget extends StatelessWidget {
  /// Creates a [LinesWidget].
  const LinesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final node = ScopedTreeNode.of(context).node;

    final theme = TreeView.of(context).theme;

    final indentation = node.calculateIndentation(theme.indent);

    late final child = SizedBox(
      width: indentation,
      height: double.infinity,
    );

    switch (theme.lineStyle) {
      case LineStyle.scoped:
        return CustomPaint(
          painter: LinesPainter(
            linesToBeDrawn: node.scopedLines,
            theme: theme,
          ),
          child: child,
        );

      case LineStyle.connected:
        return CustomPaint(
          painter: LinesPainter(
            linesToBeDrawn: node.connectedLines,
            theme: theme,
          ),
          child: child,
        );

      case LineStyle.disabled:
      default:
        return child;
    }
  }
}
