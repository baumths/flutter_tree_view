import 'internal.dart';

/// Defines how a single line should be shaped
enum TreeLine {
  /// No line should be drawn, (used to align adjacent lines)
  blank,

  /// 'L' connection (used for the last child of a node)
  connection,

  /// 'T' intersection (used when the node has next sibling)
  intersection,

  /// '|' from top to bottom (used to connect nodes)
  straight,
}

// TODO: Implement curved corners for [TreeLine].`connection`

/// This class is used to calculate and
/// draw the lines that compose a single node in the [TreeView] widget.
class LinesPainter extends CustomPainter {
  /// Creates a [LinesPainter].
  LinesPainter({required this.theme, required this.linesToBeDrawn});

  /// The theme to use to draw the lines.
  final TreeViewTheme theme;

  /// The list of lines that will be drawn.
  late final List<TreeLine> linesToBeDrawn;

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

      final offset = _LineOffset(
        height: size.height,
        width: theme.indent,
        index: index,
        lineCount: linesToBeDrawn.length,
      );

      canvas.drawPath(offset.draw(linesToBeDrawn[index]), paint);
    }
  }

  @override
  bool shouldRepaint(covariant LinesPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}

class _LineOffset {
  _LineOffset({
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
      case TreeLine.intersection:
        return _drawIntersection();

      case TreeLine.straight:
        return _drawStraight();

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
}
