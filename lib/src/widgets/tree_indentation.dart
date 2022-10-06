import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import '../foundation.dart' show TreeEntry, TreeNode;

/// Widget responsible for indenting tree nodes and painting lines (if enabled).
///
/// See also:
///
/// * [IndentGuide], an interface for working with any type of decoration. By
///   default, an [IndentGuide] only indents nodes, without any decoration;
/// * [AbstractLineGuide], an interface for working with line painting;
///
/// * [ScopingLinesGuide], which paints vertical lines for each level of the
///   tree;
/// * [ConnectingLinesGuide], which paints vertical lines with horizontal
///   connections;
///
/// * [DefaultIndentGuide], an [InheritedTheme] that provides an [IndentGuide]
///   to its descendant widgets.
class TreeIndentation<T extends TreeNode<T>> extends StatelessWidget {
  /// Creates a [TreeIndentation].
  ///
  /// If [guide] is not provided, defaults to a constant [ConnectingLinesGuide].
  const TreeIndentation({
    super.key,
    required this.child,
    required this.treeEntry,
    this.guide,
  });

  /// The tree entry that will be used to calculate the total indentation and
  /// paint guides for (if enabled).
  final TreeEntry<T> treeEntry;

  /// The widget that is going to be displayed to the side of indentation.
  final Widget child;

  /// The configuration used to indent and paint lines (if enabled).
  ///
  /// If not provided, [DefaultIndentGuide.of] will be used.
  ///
  /// See also:
  ///
  /// * [ScopingLinesGuide], which paints vertical lines for each level of the
  ///   tree;
  /// * [ConnectingLinesGuide], which paints vertical lines with horizontal
  ///   connections;
  ///
  /// * [IndentGuide], an interface for working with any type of decoration. By
  ///   default, an [IndentGuide] only indents nodes, without any decoration;
  /// * [AbstractLineGuide], an interface for working with line painting;
  final IndentGuide? guide;

  @override
  Widget build(BuildContext context) {
    if (treeEntry.level == 0) {
      return child;
    }

    final IndentGuide effectiveGuide = guide ?? DefaultIndentGuide.of(context);
    return effectiveGuide.wrap<T>(context, child, treeEntry);
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
/// See also:
///
/// * [IndentGuide], an interface for working with any type of decoration. By
///   default, an [IndentGuide] only indents nodes, without any decoration;
/// * [AbstractLineGuide], an interface for working with line painting;
///
/// * [ScopingLinesGuide], which paints vertical lines for each level of the
///   tree;
/// * [ConnectingLinesGuide], which paints vertical lines with horizontal
///   connections;
class DefaultIndentGuide extends InheritedTheme {
  /// Creates a [DefaultIndentGuide].
  const DefaultIndentGuide({
    super.key,
    required super.child,
    required this.guide,
  });

  /// The default [IndentGuide] provided to the widget tree of [child].
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

/// The configurations of tree node indentation.
///
/// By default, using [IndenGuide] only adds the space necessary to indent a
/// node, with no decorations.
///
/// To add decorations to the indentation of nodes, see:
///
/// See also:
///
/// * [ScopingLinesGuide], which paints vertical lines for each level of the
///   tree;
/// * [ConnectingLinesGuide], which paints vertical lines with horizontal
///   connections;
///
/// * [AbstractLineGuide], an interface for working with line painting;
class IndentGuide {
  /// Allows subclasses to have constant constructors.
  const IndentGuide({
    this.indent = 40.0,
  }) : assert(indent >= 0.0);

  /// The amount of indent to apply for each level of the tree.
  ///
  /// Example:
  ///
  /// ```dart
  /// final TreeEntry<T> entry;
  /// final IndentGuide guide;
  /// final double indentation = entry.level * guide.indent;
  /// ```
  final double indent;

  /// Method used to wrap [child] in the desired decoration/painting.
  ///
  /// Subclasses must override this method if they want to customize whats
  /// shown inside of [TreeIndentation].
  ///
  /// See also:
  ///
  ///   * [AbstractLineGuide], an interface for working with line painting;
  Widget wrap<T extends TreeNode<T>>(
    BuildContext context,
    Widget child,
    TreeEntry<T> entry,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: entry.level * indent),
      child: child,
    );
  }

  @override
  int get hashCode => indent.hashCode;

  @override
  operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IndentGuide && other.indent == indent;
  }
}

/// An interface for configuring how to paint line guides in the indentation of
/// a tree node.
///
/// See also:
///
/// * [ScopingLinesGuide], which paints vertical lines for each level of the
///   tree;
/// * [ConnectingLinesGuide], which paints vertical lines with horizontal
///   connections;
///
/// * [IndentGuide], an interface for working with any type of decoration. By
///   default, an [IndentGuide] only indents nodes, without any decoration;
abstract class AbstractLineGuide extends IndentGuide {
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

  /// Creates the [Paint] object that will be used to paint lines.
  Paint createPaint() => Paint()
    ..color = color
    ..strokeWidth = thickness
    ..style = PaintingStyle.stroke;

  /// Calculates the origin offset of the line drawn for the given [level].
  double offsetOfLevel(int level) => (level * indent) - originOffset;
}

/// Simple configuration for painting vertical lines at every level of the tree.
///
/// See also:
///
/// * [ConnectingLinesGuide], which paints vertical lines with horizontal
///   connections;
///
/// * [IndentGuide], an interface for working with any type of decoration. By
///   default, an [IndentGuide] only indents nodes, without any decoration;
/// * [AbstractLineGuide], an interface for working with line painting;
class ScopingLinesGuide extends AbstractLineGuide {
  /// Creates a [ScopingLinesGuide].
  const ScopingLinesGuide({
    super.indent,
    super.color,
    super.thickness,
    super.origin,
  });

  @override
  Widget wrap<T extends TreeNode<T>>(
    BuildContext context,
    Widget child,
    TreeEntry<T> entry,
  ) {
    return CustomPaint(
      painter: _ScopingLinesPainter(
        guide: this,
        entryLevel: entry.level,
        textDirection: Directionality.maybeOf(context),
      ),
      child: super.wrap<T>(context, child, entry),
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

    return other is AbstractLineGuide &&
        other.indent == indent &&
        other.color == color &&
        other.thickness == thickness &&
        other.origin == origin;
  }
}

class _ScopingLinesPainter extends CustomPainter {
  _ScopingLinesPainter({
    required this.guide,
    required this.entryLevel,
    required this.textDirection,
  });

  final ScopingLinesGuide guide;
  final int entryLevel;
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

    for (int level = 1; level <= entryLevel; level++) {
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
      oldDelegate.entryLevel != entryLevel ||
      oldDelegate.textDirection != textDirection;
}

/// Simple configuration for painting vertical lines that have a horizontal
/// connection to its tree entry.
///
/// See also:
///
/// * [ScopingLinesGuide], which paints vertical lines for each level of the
///   tree;
///
/// * [IndentGuide], an interface for working with any type of decoration. By
///   default, an [IndentGuide] only indents nodes, without any decoration;
/// * [AbstractLineGuide], an interface for working with line painting;
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
  Widget wrap<T extends TreeNode<T>>(
    BuildContext context,
    Widget child,
    TreeEntry<T> entry,
  ) {
    return CustomPaint(
      painter: _ConnectingLinesPainter(
        guide: this,
        entryLevel: entry.level,
        hasNextSibling: entry.hasNextSibling,
        ancestorLevelsWithLines: entry.ancestorLevelsWithVerticalLines,
        textDirection: Directionality.maybeOf(context),
      ),
      child: super.wrap<T>(context, child, entry),
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

    return other is ConnectingLinesGuide &&
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
    required this.entryLevel,
    required this.hasNextSibling,
    required this.ancestorLevelsWithLines,
    this.textDirection,
  }) : indentation = entryLevel * guide.indent;

  final ConnectingLinesGuide guide;
  final int entryLevel;
  final bool hasNextSibling;
  final Set<int> ancestorLevelsWithLines;
  final TextDirection? textDirection;
  final double indentation;

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

    for (final int level in ancestorLevelsWithLines) {
      final double x = calculateOffset(level);
      path
        ..moveTo(x, size.height)
        ..lineTo(x, 0);
    }

    // Add connection

    final double y = size.height * 0.5;

    path.moveTo(connectionStart, 0.0);

    if (guide.roundCorners) {
      path.quadraticBezierTo(connectionStart, y, connectionEnd, y);
    } else {
      // if the entry has a sibling after it, a full vertical line was drawn at
      // [entryLevel] by [addVerticalLines] and we only need to move to the
      // start of the horizontal line, otherwise we must add half vertical line
      // to connect to the horizontal one.
      if (hasNextSibling) {
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
      oldDelegate.entryLevel != entryLevel ||
      oldDelegate.hasNextSibling != hasNextSibling ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.guide != guide ||
      !setEquals(oldDelegate.ancestorLevelsWithLines, ancestorLevelsWithLines);
}
