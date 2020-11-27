import 'internal.dart';

/// Defines how a single line should be shaped
enum TreeLine {
  /// No line should be drawn, (used to align adjacent lines)
  blank,

  /// 'T' intersection (used when the node has next sibling)
  intersection,

  /// 'L' connection (used for the last child of a node)
  connection,

  /// '|' from top to bottom (used to connect nodes)
  straight,

  /// '|' from center to bottom (used to connect parent with children lines)
  link,
}

// TODO: implement custom constructor/class for different lineStyle.

// TODO: Implement curved corners for [TreeLine].`connection`

/// This class is used to calculate and
/// draw the lines that compose a single node in the [TreeView] widget.
class LinesPainter extends CustomPainter {
  LinesPainter.connected({required this.node, required this.theme}) {
    node.lines = node.isRoot ? [] : buildConnectedLines(node.parent!.lines);
    linesToBeDrawn = <TreeLine>[
      ...node.lines,
      if (theme.shouldDrawLinkLine && node.hasChildren && node.isExpanded)
        TreeLine.link,
    ];
  }

  LinesPainter.scoped({required this.node, required this.theme}) {
    node.lines = buildScopedLines();
    linesToBeDrawn = List<TreeLine>.from(node.lines);
  }

  /// List of lines to be drawn for a single node. (Copy from [node.lines]).
  late final List<TreeLine> linesToBeDrawn;

  final TreeNode node;

  final TreeViewTheme theme;

  int get lineCount => linesToBeDrawn.last == TreeLine.link
      ? linesToBeDrawn.length - 1
      : linesToBeDrawn.length;

  List<TreeLine> buildConnectedLines(List<TreeLine> parentLines) {
    final hasNextSibling = node.hasNextSibling;

    if (node.isMostTopLevel) {
      return [hasNextSibling ? TreeLine.intersection : TreeLine.connection];
    }
    return [
      ...parentLines.sublist(0, parentLines.length - 1),
      parentLines.last == TreeLine.intersection
          ? TreeLine.straight
          : TreeLine.blank,
      hasNextSibling ? TreeLine.intersection : TreeLine.connection,
    ];
  }

  List<TreeLine> buildScopedLines() {
    if (node.isMostTopLevel) return const [];
    return List<TreeLine>.generate(
      node.depth - 1,
      (_) => TreeLine.straight,
      growable: false,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.lineThickness
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < linesToBeDrawn.length; index++) {
      if (linesToBeDrawn[index] == TreeLine.blank) continue;

      final offset = LineOffset(
        height: size.height,
        width: theme.singleLineWidth,
        index: index,
        lineCount: lineCount,
      );

      canvas.drawPath(offset.draw(linesToBeDrawn[index]), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinesPainter oldDelegate) => false;
}

class LineOffset {
  LineOffset({
    required this.height,
    required this.width,
    required this.index,
    required this.lineCount,
  });
  final double height;
  final double width;
  final int index;
  final int lineCount;

  late final double xStart = width * index;

  late final double xEnd = width * lineCount;

  late final double centerX = xStart + width * 0.5;

  late final double centerY = height * 0.5;

  Path draw(TreeLine line) {
    switch (line) {
      case TreeLine.straight:
        return _drawStraight();

      case TreeLine.intersection:
        return _drawIntersection();

      case TreeLine.link:
        return _drawLink();

      case TreeLine.connection:
      default:
        return _drawConnection();
    }
  }

  Path _drawStraight() => Path()
    ..moveTo(centerX, 0)
    ..lineTo(centerX, height);

  Path _drawConnection() => Path()
    ..moveTo(centerX, 0)
    ..lineTo(centerX, centerY)
    ..lineTo(xEnd, centerY);

  Path _drawIntersection() => Path()
    ..moveTo(centerX, 0)
    ..lineTo(centerX, height)
    ..moveTo(centerX, centerY)
    ..lineTo(xEnd, centerY);

  Path _drawLink() => Path()
    ..moveTo(centerX, centerY)
    ..lineTo(centerX, height);
}
