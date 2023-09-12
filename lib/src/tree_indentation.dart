import 'package:flutter/material.dart';

import 'tree_controller.dart' show TreeEntry;

/// Widget responsible for indenting tree nodes and painting lines (if enabled).
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
///
/// Example:
/// ```dart
/// final TreeEntry entry;
///
/// @override
/// Widget build(BuildContext context) {
///   return TreeIndentation(
///     entry: entry,
///     guide: IndentGuide.connectingLines(
///       indent: 40,
///       color: Colors.grey,
///       thickness: 1.0,
///       origin: 0.5,
///       roundCorners: true,
///     ),
///     child: ...
///   );
/// }
/// ```
///
/// If [guide] is not provided, [DefaultIndentGuide.of] will be used instead.
class TreeIndentation extends StatelessWidget {
  /// Creates a [TreeIndentation].
  ///
  /// If [guide] is not provided, [DefaultIndentGuide.of] will be used instead.
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

/// The configuration used to indent and paint optional guides for tree nodes.
///
/// This indent guide only indents tree nodes without decorations. Check out the
/// factory constructors of this class to discover the available indent guide
/// decorations.
class IndentGuide {
  /// Creates an [IndentGuide].
  const IndentGuide({
    this.indent = 40.0,
    this.padding = EdgeInsets.zero,
  }) : assert(indent >= 0.0);

  /// Convenient constructor to create a [ConnectingLinesGuide].
  const factory IndentGuide.connectingLines({
    double indent,
    EdgeInsetsGeometry padding,
    Color color,
    double thickness,
    double origin,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
    PathModifier? pathModifier,
    bool roundCorners,
    bool connectBranches,
  }) = ConnectingLinesGuide;

  /// Convenient constructor to create a [ScopingLinesGuide].
  const factory IndentGuide.scopingLines({
    double indent,
    EdgeInsetsGeometry padding,
    Color color,
    double thickness,
    double origin,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
    PathModifier? pathModifier,
  }) = ScopingLinesGuide;

  /// The amount of indent to apply for each level of the tree.
  ///
  /// The indentation of tree nodes is calculated as follows:
  /// ```dart
  /// final TreeEntry entry;
  /// final IndentGuide guide;
  /// final double indentation = entry.level * guide.indent;
  /// ```
  final double indent;

  /// The amount of space to inset [TreeIndentation.child].
  ///
  /// The indentation of tree nodes will be added to this object, i.e.,
  /// `padding.add(EdgeInsetsDirectional.only(start: indentation))`.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry padding;

  /// Method used to wrap [child] in the desired decoration/painting.
  ///
  /// Subclasses must override this method to customize whats shown inside of
  /// [TreeIndentation].
  ///
  /// See also:
  /// * [AbstractLineGuide], an interface for working with line painting;
  Widget wrap(BuildContext context, Widget child, TreeEntry<Object> entry) {
    return Padding(
      padding: padding.add(
        EdgeInsetsDirectional.only(start: entry.level * indent),
      ),
      child: child,
    );
  }

  /// Creates a copy of this indent guide but with the given fields replaced
  /// with the new values.
  IndentGuide copyWith({
    double? indent,
    EdgeInsetsGeometry? padding,
  }) {
    return IndentGuide(
      indent: indent ?? this.indent,
      padding: padding ?? this.padding,
    );
  }

  @override
  int get hashCode => Object.hash(indent, padding);

  @override
  operator ==(Object other) {
    if (identical(other, this)) return true;

    return other.runtimeType == runtimeType &&
        other is IndentGuide &&
        other.indent == indent &&
        other.padding == padding;
  }
}

/// Signature for a function that takes a [Path] and returns a [Path].
///
/// Used by the tree line painters to update the tree line path if desired.
typedef PathModifier = Path Function(Path path);

/// An interface for configuring how to paint line guides in the indentation of
/// a tree node.
///
/// Check out the factory constructors of [IndentGuide] to discover the
/// available indent guide decorations.
abstract class AbstractLineGuide extends IndentGuide {
  /// Constructor with requried parameters for building the indent line guides.
  const AbstractLineGuide({
    super.indent,
    super.padding,
    this.color = Colors.grey,
    this.thickness = 2.0,
    this.origin = 0.5,
    this.strokeCap = StrokeCap.butt,
    this.strokeJoin = StrokeJoin.miter,
    this.pathModifier,
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

  /// The kind of finish to place on the end of lines drawn.
  ///
  /// Defaults to [StrokeCap.butt], i.e. no caps.
  final StrokeCap strokeCap;

  /// The kind of finish to place on the joins between line segments.
  ///
  /// Defaults to [StrokeJoin.miter], i.e. sharp corners.
  final StrokeJoin strokeJoin;

  /// An optional mapper callback that can be used to apply some styling to tree
  /// lines like dashing and dotting.
  ///
  /// When defined, this is called right before drawing lines on the canvas.
  ///
  /// A [Path] instance containing all computed tree line segments is provided
  /// to this callback which should then apply the desired transformations and
  /// return either the same or a new [Path] instance.
  ///
  /// Example using the [path_drawing](https://pub.dev/packages/path_drawing)
  /// package:
  /// ```dart
  /// import 'package:path_drawing/path_drawing.dart';
  ///
  /// Path dashingModifier(Path path) {
  ///   return dashPath(
  ///     path,
  ///     dashArray: CircularIntervalList(const <double>[8.0, 2.0]),
  ///     dashOffset: const DashOffset.absolute(1),
  ///   );
  /// }
  ///
  /// Path dottingModifier(Path path) {
  ///   return dashPath(
  ///     path,
  ///     dashArray: CircularIntervalList(const <double>[2.0]),
  ///     dashOffset: const DashOffset.absolute(1),
  ///   );
  /// }
  /// ```
  /// > The values above should be tweaked to reach the desired result.
  final PathModifier? pathModifier;

  /// Subclasses must override this method to provide the [CustomPainter] that
  /// will handle line painting.
  CustomPainter createPainter(BuildContext context, TreeEntry<Object> entry);

  /// Creates the [Paint] object that will be used to draw lines.
  Paint createPaint() => Paint()
    ..color = color
    ..strokeWidth = thickness
    ..strokeCap = strokeCap
    ..strokeJoin = strokeJoin
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
    super.padding,
    super.color,
    super.thickness,
    super.origin,
    super.strokeCap,
    super.strokeJoin,
    super.pathModifier,
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
  @override
  ScopingLinesGuide copyWith({
    double? indent,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? thickness,
    double? origin,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    PathModifier? Function()? pathModifier,
  }) {
    return ScopingLinesGuide(
      indent: indent ?? this.indent,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      origin: origin ?? this.origin,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      pathModifier: pathModifier != null ? pathModifier() : this.pathModifier,
    );
  }

  @override
  int get hashCode => Object.hash(
        indent,
        padding,
        color,
        thickness,
        origin,
        strokeCap,
        strokeJoin,
        pathModifier,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other.runtimeType == runtimeType &&
        other is ScopingLinesGuide &&
        other.indent == indent &&
        other.padding == padding &&
        other.color == color &&
        other.thickness == thickness &&
        other.origin == origin &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin &&
        other.pathModifier == pathModifier;
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
      path.moveTo(x, size.height);
      path.lineTo(x, 0);
    }

    canvas.drawPath(
      guide.pathModifier?.call(path) ?? path,
      guide.createPaint(),
    );
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
    super.padding,
    super.color,
    super.thickness,
    super.origin,
    super.strokeCap,
    super.strokeJoin,
    super.pathModifier,
    this.roundCorners = false,
    this.connectBranches = false,
  });

  /// Decides if the connection between vertical and horizontal lines should be
  /// rounded.
  final bool roundCorners;

  /// Decides if the horizontal connection should be extended one level further
  /// (and connect to descendant lines, if any).
  ///
  /// When set to true, the horizontal connection will be extended to the next
  /// level and if the node has child nodes under it, the line will be extended
  /// downwards to connect a parent and its subtree.
  ///
  /// The `┐` connection is only drawn for nodes that are both expanded and
  /// have at least one child node. If this is set to true and a tree node
  /// doesn't match the above conditions, the connection is only extended
  /// horizontally to the next level.
  ///
  /// Defaults to `false`.
  final bool connectBranches;

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
  @override
  ConnectingLinesGuide copyWith({
    double? indent,
    EdgeInsetsGeometry? padding,
    Color? color,
    double? thickness,
    double? origin,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    PathModifier? Function()? pathModifier,
    bool? roundCorners,
    bool? connectBranches,
  }) {
    return ConnectingLinesGuide(
      indent: indent ?? this.indent,
      padding: padding ?? this.padding,
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      origin: origin ?? this.origin,
      strokeCap: strokeCap ?? this.strokeCap,
      strokeJoin: strokeJoin ?? this.strokeJoin,
      pathModifier: pathModifier != null ? pathModifier() : this.pathModifier,
      roundCorners: roundCorners ?? this.roundCorners,
      connectBranches: connectBranches ?? this.connectBranches,
    );
  }

  @override
  int get hashCode => Object.hash(
        indent,
        padding,
        color,
        thickness,
        origin,
        strokeCap,
        strokeJoin,
        pathModifier,
        roundCorners,
        connectBranches,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other.runtimeType == runtimeType &&
        other is ConnectingLinesGuide &&
        other.indent == indent &&
        other.padding == padding &&
        other.color == color &&
        other.thickness == thickness &&
        other.origin == origin &&
        other.strokeCap == strokeCap &&
        other.strokeJoin == strokeJoin &&
        other.pathModifier == pathModifier &&
        other.roundCorners == roundCorners &&
        other.connectBranches == connectBranches;
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

  void runForEachAncestorLevelThatHasNextSibling(ValueChanged<int> action) {
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
    final double Function(int level) calculateOffset;
    double connectionEnd;
    double connectionStart;

    if (textDirection == TextDirection.rtl) {
      calculateOffset = (int level) => size.width - guide.offsetOfLevel(level);
      connectionStart = size.width - (indentation - guide.originOffset);
      connectionEnd = connectionStart - guide.indent * 0.5;
    } else {
      calculateOffset = guide.offsetOfLevel;
      connectionStart = indentation - guide.originOffset;
      connectionEnd = connectionStart + guide.indent * 0.5;
    }

    final Path path = Path();

    // Add vertical lines
    runForEachAncestorLevelThatHasNextSibling((int level) {
      final double x = calculateOffset(level);
      path.moveTo(x, size.height);
      path.lineTo(x, 0);
    });

    // Add connections
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

    if (guide.connectBranches) {
      connectionEnd = calculateOffset(entry.level + 1);

      if (entry.isExpanded && entry.hasChildren) {
        if (guide.roundCorners) {
          path.quadraticBezierTo(connectionEnd, y, connectionEnd, size.height);
        } else {
          path.lineTo(connectionEnd, y);
          path.lineTo(connectionEnd, size.height);
        }
      } else {
        path.lineTo(connectionEnd, y);
      }
    }

    canvas.drawPath(
      guide.pathModifier?.call(path) ?? path,
      guide.createPaint(),
    );
  }

  @override
  bool shouldRepaint(covariant _ConnectingLinesPainter oldDelegate) =>
      oldDelegate.entry != entry ||
      oldDelegate.textDirection != textDirection ||
      oldDelegate.guide != guide;
}
