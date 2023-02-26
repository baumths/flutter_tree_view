import 'package:flutter/material.dart';

import '../foundation/tree_controller.dart';

/// Widget responsible for indenting tree nodes and painting lines (if enabled).
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
class TreeIndentation extends StatelessWidget {
  /// Creates a [TreeIndentation].
  ///
  /// If [guide] is not provided, defaults to a constant [ConnectingLinesGuide].
  const TreeIndentation({
    super.key,
    required this.child,
    required this.entry,
    this.guide,
  });

  /// The widget that is going to be displayed to the side of the indentation.
  final Widget child;

  /// The [TreeEntry] that will provide the relevant details (i.e., level,
  /// line offsets, etc.) when indenting and/or painting indent guides.
  final TreeEntry<Object> entry;

  /// The configuration used to indent and paint lines (if enabled).
  ///
  /// If not provided, [DefaultIndentGuide.of] will be used.
  ///
  /// Check out the factory constructors of [IndentGuide] to discover the
  /// available indent guide decorations.
  final IndentGuide? guide;

  @override
  Widget build(BuildContext context) {
    if (entry.skipIndentAndPaint) {
      return child;
    }

    final IndentGuide effectiveGuide = guide ?? DefaultIndentGuide.of(context);
    return effectiveGuide.wrap(context, child, entry);
  }
}

/// An [InheritedTheme] that provides a default [IndentGuide] to its widget tree.
///
/// The [TreeIndentation] widget will use the value returned from
/// [DefaultIndentGuide.of] if its internal [TreeIndentation.guide] is `null`.
///
/// If [TreeIndentation.guide] is `null` and there's no [DefaultIndentGuide] in
/// its context, a default [ConnectingLinesGuide] will be returned.
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
class DefaultIndentGuide extends InheritedTheme {
  /// Creates a [DefaultIndentGuide].
  const DefaultIndentGuide({
    super.key,
    required super.child,
    required this.guide,
  });

  /// The default [IndentGuide] provided to the widget tree of [child].
  ///
  /// Check out the factory constructors of [IndentGuide] to discover the
  /// available indent guide decorations.
  final IndentGuide guide;

  /// The [IndentGuide] from the closest instance of this class that encloses
  /// the given context.
  ///
  /// If there is no [DefaultIndentGuide] ancestor in the widget tree at the
  /// given context, then this will return a [ConnectingLinesGuide] with its
  /// default constructor values.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// IndentGuide guide = DefaultIndentGuide.of(context);
  /// ```
  static IndentGuide of(BuildContext context) {
    final DefaultIndentGuide? instance =
        context.dependOnInheritedWidgetOfExactType<DefaultIndentGuide>();

    return instance?.guide ?? const ConnectingLinesGuide();
  }

  @override
  bool updateShouldNotify(DefaultIndentGuide oldWidget) {
    return oldWidget.guide != guide;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return DefaultIndentGuide(guide: guide, child: child);
  }
}

/// An interface to configure tree node indentation and painting.
///
/// Check out the factory constructors of this class to discover the
/// available indent guide decorations.
abstract class IndentGuide {
  /// Allows subclasses to have constant constructors.
  const IndentGuide({
    this.indent = 40.0,
  }) : assert(indent >= 0.0);

  /// Convenient constructor to create a [BlankIndentGuide].
  const factory IndentGuide.blank({double indent}) = BlankIndentGuide;

  /// Convenient constructor to create a [ConnectingLinesGuide].
  const factory IndentGuide.connectingLines({
    double indent,
    Color color,
    double thickness,
    double origin,
    bool roundCorners,
  }) = ConnectingLinesGuide;

  /// Convenient constructor to create a [ScopingLinesGuide].
  const factory IndentGuide.scopingLines({
    double indent,
    Color color,
    double thickness,
    double origin,
  }) = ScopingLinesGuide;

  /// The amount of indent to apply for each level of the tree.
  ///
  /// Example:
  ///
  /// ```dart
  /// final TreeEntry entry;
  /// final IndentGuide guide;
  /// final double indentation = entry.level * guide.indent;
  /// ```
  final double indent;

  /// Method used to wrap [child] in the desired decoration/painting.
  ///
  /// Subclasses must override this method to customize whats shown inside of
  /// [TreeIndentation].
  ///
  /// See also:
  ///
  ///   * [AbstractLineGuide], an interface for working with line painting;
  Widget wrap(BuildContext context, Widget child, TreeEntry<Object> entry);

  @override
  int get hashCode => indent.hashCode;

  @override
  operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IndentGuide && other.indent == indent;
  }
}

/// An [IndentGuide] that only indents tree nodes, with no painting.
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
class BlankIndentGuide extends IndentGuide {
  /// Creates a [BlankIndentGuide].
  const BlankIndentGuide({super.indent});

  @override
  Widget wrap(BuildContext context, Widget child, TreeEntry<Object> entry) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: entry.level * indent),
      child: child,
    );
  }

  @override
  int get hashCode => indent.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other.runtimeType == runtimeType &&
        other is BlankIndentGuide &&
        other.indent == indent;
  }
}

/// An interface for configuring how to paint line guides in the indentation of
/// a tree node.
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
abstract class AbstractLineGuide extends BlankIndentGuide {
  /// Constructor with requried parameters for building the indent line guides.
  const AbstractLineGuide({
    super.indent,
    this.color = Colors.grey,
    this.thickness = 2.0,
    this.origin = 0.5,
  })  : assert(thickness >= 0.0),
        assert(
          0.0 <= origin && origin <= 1.0,
          '`origin` must be a value between `0.0` and `1.0`.',
        ),
        originOffset = indent - (indent * origin);

  /// The color to use when painting the lines on the canvas.
  ///
  /// Defaults to [Colors.grey].
  final Color color;

  /// The width each line should have.
  ///
  /// Defaults to `2.0`.
  final double thickness;

  /// Defines where horizontally inside [indent] to start painting the vertical
  /// lines.
  ///
  /// The [originOffset] is calculated from [indent] and [origin]:
  /// ```dart
  /// final double originOffset = indent - (indent * origin);
  /// ```
  ///
  /// Must be a value between `0.0` and `1.0`, Being:
  /// - `0.0`: start;
  /// - `0.5`: center;
  /// - `1.0`: end;
  final double origin;

  /// The value that results from `indent - (indent * origin)`.
  ///
  /// Used when painting to horizontally position a line on each [indent] level.
  final double originOffset;

  /// Subclasses must override this method to provide the [CustomPainter] that
  /// will handle painting.
  CustomPainter createPainter(BuildContext context, TreeEntry<Object> entry);

  /// Creates the [Paint] object that will be used to paint lines.
  Paint createPaint() => Paint()
    ..color = color
    ..strokeWidth = thickness
    ..style = PaintingStyle.stroke;

  /// Calculates the origin offset of the line drawn for the given [level].
  double offsetOfLevel(int level) => (level * indent) - originOffset;

  @override
  Widget wrap(BuildContext context, Widget child, TreeEntry<Object> entry) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: createPainter(context, entry),
        child: super.wrap(context, child, entry),
      ),
    );
  }
}

/// The [IndentGuide] configuration for painting vertical lines at every level
/// of the tree.
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
class ScopingLinesGuide extends AbstractLineGuide {
  /// Creates a [ScopingLinesGuide].
  const ScopingLinesGuide({
    super.indent,
    super.color,
    super.thickness,
    super.origin,
  });

  @override
  CustomPainter createPainter(BuildContext context, TreeEntry<Object> entry) {
    return _ScopingLinesPainter(
      guide: this,
      nodeLevel: entry.level,
      textDirection: Directionality.maybeOf(context),
    );
  }

  /// Creates a copy of this indent guide but with the given fields replaced
  /// with the new values.
  ScopingLinesGuide copyWith({
    double? indent,
    Color? color,
    double? thickness,
    double? origin,
  }) {
    return ScopingLinesGuide(
      indent: indent ?? this.indent,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      origin: origin ?? this.origin,
    );
  }

  @override
  int get hashCode => Object.hash(
        indent,
        color,
        thickness,
        origin,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other.runtimeType == runtimeType &&
        other is ScopingLinesGuide &&
        other.indent == indent &&
        other.color == color &&
        other.thickness == thickness &&
        other.origin == origin;
  }
}

class _ScopingLinesPainter extends CustomPainter {
  _ScopingLinesPainter({
    required this.guide,
    required this.nodeLevel,
    required this.textDirection,
  });

  final ScopingLinesGuide guide;
  final int nodeLevel;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    late double Function(int level) calculateOffset;

    if (textDirection == TextDirection.rtl) {
      calculateOffset = (int level) => size.width - guide.offsetOfLevel(level);
    } else {
      calculateOffset = guide.offsetOfLevel;
    }

    final Path path = Path();

    for (int level = 1; level <= nodeLevel; level++) {
      final double x = calculateOffset(level);
      path
        ..moveTo(x, size.height)
        ..lineTo(x, 0);
    }

    canvas.drawPath(path, guide.createPaint());
  }

  @override
  bool shouldRepaint(covariant _ScopingLinesPainter oldDelegate) =>
      oldDelegate.guide != guide ||
      oldDelegate.nodeLevel != nodeLevel ||
      oldDelegate.textDirection != textDirection;
}

/// The [IndentGuide] configuration for painting vertical lines that have a
/// horizontal connection to its tree node.
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
class ConnectingLinesGuide extends AbstractLineGuide {
  /// Creates a [ConnectingLinesGuide].
  const ConnectingLinesGuide({
    super.indent,
    super.color,
    super.thickness,
    super.origin,
    this.roundCorners = false,
  });

  /// Determines if the connection between a horizontal and a vertical line
  /// should be rounded.
  final bool roundCorners;

  @override
  CustomPainter createPainter(BuildContext context, TreeEntry<Object> entry) {
    return _ConnectingLinesPainter(
      guide: this,
      entry: entry,
      textDirection: Directionality.maybeOf(context),
    );
  }

  /// Creates a copy of this indent guide but with the given fields replaced
  /// with the new values.
  ConnectingLinesGuide copyWith({
    double? indent,
    Color? color,
    double? thickness,
    double? origin,
    bool? roundCorners,
  }) {
    return ConnectingLinesGuide(
      indent: indent ?? this.indent,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      origin: origin ?? this.origin,
      roundCorners: roundCorners ?? this.roundCorners,
    );
  }

  @override
  int get hashCode => Object.hash(
        indent,
        color,
        thickness,
        origin,
        roundCorners,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other.runtimeType == runtimeType &&
        other is ConnectingLinesGuide &&
        other.indent == indent &&
        other.color == color &&
        other.thickness == thickness &&
        other.origin == origin &&
        other.roundCorners == roundCorners;
  }
}

class _ConnectingLinesPainter extends CustomPainter {
  _ConnectingLinesPainter({
    required this.guide,
    required this.entry,
    this.textDirection,
  }) : indentation = entry.level * guide.indent;

  final ConnectingLinesGuide guide;
  final TreeEntry<Object> entry;
  final TextDirection? textDirection;
  final double indentation;

  void runForEachAncestorLevelThatHasNextSibling(
    void Function(int level) action,
  ) {
    entry.unreachableAncestorLevelsWithVerticalLines?.forEach(action);

    TreeEntry<Object>? current = entry;
    while (current != null && current.level > 0) {
      if (current.hasNextSibling) {
        action(current.level);
      }
      current = current.parent;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    late double connectionEnd;
    late double connectionStart;
    late double Function(int level) calculateOffset;

    if (textDirection == TextDirection.rtl) {
      connectionEnd = size.width - indentation;
      connectionStart = connectionEnd + guide.originOffset;
      calculateOffset = (int level) => size.width - guide.offsetOfLevel(level);
    } else {
      connectionEnd = indentation;
      connectionStart = indentation - guide.originOffset;
      calculateOffset = guide.offsetOfLevel;
    }

    final Path path = Path();

    // Add vertical lines
    runForEachAncestorLevelThatHasNextSibling((int level) {
      final double x = calculateOffset(level);
      path
        ..moveTo(x, size.height)
        ..lineTo(x, 0);
    });

    // Add connection

    final double y = size.height * 0.5;

    path.moveTo(connectionStart, 0.0);

    if (guide.roundCorners) {
      path.quadraticBezierTo(connectionStart, y, connectionEnd, y);
    } else {
      // if [entry] has a sibling after it, a full vertical line was
      // painted at [entry.level] and we only need to move to the start
      // of the horizontal line, otherwise add half of a vertical line
      // to connect to the horizontal one.
      if (entry.hasNextSibling) {
        path.moveTo(connectionStart, y);
      } else {
        path.lineTo(connectionStart, y);
      }

      path.lineTo(connectionEnd, y);
    }

    canvas.drawPath(path, guide.createPaint());
  }

  @override
  bool shouldRepaint(covariant _ConnectingLinesPainter oldDelegate) =>
      oldDelegate.entry.level != entry.level ||
      oldDelegate.entry.hasNextSibling != entry.hasNextSibling ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.guide != guide;
}
