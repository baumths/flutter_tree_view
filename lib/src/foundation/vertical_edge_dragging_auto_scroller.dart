import 'dart:math' as math show max, min;

import 'package:flutter/material.dart';

// Most code in this file was copied from `flutter/widgets/reordarable_list.dart`.

/// An auto scroller that scrolls the [scrollable] if a drag gesture drags close
/// to its top/bottom edges.
class VerticalEdgeDraggingAutoScroller {
  /// Creates an auto scroller that scrolls the [scrollable].
  VerticalEdgeDraggingAutoScroller({
    required this.scrollable,
    this.onScrollViewScrolled,
  })  : assert(
          scrollable.position.axis == Axis.vertical,
          '`VerticalEdgeDraggingAutoScroller` was given a horizontal scrollable, '
          'but expected it to be vertical.',
        ),
        _scrollDuration = Duration(
          milliseconds: (1000 / _kDefaultVelocityScalar).round(),
        );

  final Duration _scrollDuration;

  // An eyeball value.
  // velocity = <distance of overscroll> * [_kDefaultVelocityScalar].
  static const double _kDefaultVelocityScalar = 7.0;

  static const double _kMaxOverDrag = 20.0;

  /// The [Scrollable] this auto scroller is scrolling.
  final ScrollableState scrollable;

  /// Called when a scroll view is scrolled.
  ///
  /// The scroll view may be scrolled multiple times in a roll until the drag
  /// target no longer triggers the auto scroll. This callback will be called
  /// in between each scroll.
  final VoidCallback? onScrollViewScrolled;

  late Rect _dragTargetRelatedToScrollOrigin;

  /// Whether the auto scroll is in progress.
  bool get scrolling => _scrolling;
  bool _scrolling = false;

  /// Starts the auto scroll if the [dragTarget] is close to the edge.
  ///
  /// The scroll starts to scroll the [scrollable] if the target rect is close
  /// to the edge of the [scrollable]; otherwise, it remains stationary.
  ///
  /// If the scrollable is already scrolling, calling this method updates the
  /// previous dragTarget to the new value and continue scrolling if necessary.
  void startAutoScrollIfNecessary(Rect dragTarget) {
    final Offset deltaToOrigin = scrollable.deltaToScrollOrigin;

    _dragTargetRelatedToScrollOrigin = dragTarget.translate(
      deltaToOrigin.dx,
      deltaToOrigin.dy,
    );

    if (_scrolling) {
      // The change will be picked up in the next scroll.
      return;
    }

    _scroll();
  }

  /// Stop any ongoing auto scrolling.
  void stopAutoScroll() {
    _scrolling = false;
  }

  Future<void> _scroll() async {
    final RenderBox scrollRenderBox = scrollable.renderBox;

    final Rect globalRect = MatrixUtils.transformRect(
      scrollRenderBox.getTransformTo(null),
      Offset.zero & scrollRenderBox.size,
    );

    _scrolling = true;
    double? newOffset;

    final Offset deltaToOrigin = scrollable.deltaToScrollOrigin;
    final Offset viewportOrigin = globalRect.topLeft.translate(
      deltaToOrigin.dx,
      deltaToOrigin.dy,
    );

    final double viewportStart = viewportOrigin.dy;
    final double viewportEnd = viewportStart + globalRect.size.height;

    final double proxyStart = _dragTargetRelatedToScrollOrigin.topLeft.dy;
    final double proxyEnd = _dragTargetRelatedToScrollOrigin.bottomRight.dy;

    final double pixels = scrollable.position.pixels;
    final double minScrollExtent = scrollable.position.minScrollExtent;
    final double maxScrollExtent = scrollable.position.maxScrollExtent;

    late double overDrag;

    if (scrollable.position.axis == AxisDirection.up) {
      if (proxyEnd > viewportEnd && pixels > minScrollExtent) {
        overDrag = math.max(proxyEnd - viewportEnd, _kMaxOverDrag);
        newOffset = math.max(minScrollExtent, pixels - overDrag);
      } else if (proxyStart < viewportStart && pixels < maxScrollExtent) {
        overDrag = math.max(viewportStart - proxyStart, _kMaxOverDrag);
        newOffset = math.min(maxScrollExtent, pixels + overDrag);
      }
    } else {
      if (proxyStart < viewportStart && pixels > minScrollExtent) {
        overDrag = math.max(viewportStart - proxyStart, _kMaxOverDrag);
        newOffset = math.max(minScrollExtent, pixels - overDrag);
      } else if (proxyEnd > viewportEnd && pixels < maxScrollExtent) {
        overDrag = math.max(proxyEnd - viewportEnd, _kMaxOverDrag);
        newOffset = math.min(maxScrollExtent, pixels + overDrag);
      }
    }

    if (newOffset == null || (newOffset - pixels).abs() < 1.0) {
      // Drag should not trigger scroll.
      _scrolling = false;
      return;
    }

    await scrollable.position.animateTo(
      newOffset,
      duration: _scrollDuration,
      curve: Curves.linear,
    );

    onScrollViewScrolled?.call();

    if (_scrolling) {
      await _scroll();
    }
  }
}

extension _ScrollableStateX on ScrollableState {
  RenderBox get renderBox => context.findRenderObject()! as RenderBox;

  Offset get deltaToScrollOrigin {
    switch (axisDirection) {
      case AxisDirection.down:
        return Offset(0, position.pixels);
      case AxisDirection.up:
        return Offset(0, -position.pixels);
      case AxisDirection.left:
        return Offset(-position.pixels, 0);
      case AxisDirection.right:
        return Offset(position.pixels, 0);
    }
  }
}
