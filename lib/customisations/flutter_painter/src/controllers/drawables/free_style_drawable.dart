import 'dart:ui';

import 'package:flutter/material.dart';

import 'drawable.dart';

import 'package:collection/collection.dart';

import 'package:path_drawing/path_drawing.dart';

/// Free-style Drawable (hand scribble).
class FreeStyleDrawable extends Drawable {
  /// List of points representing the path to draw.
  final List<Offset> path;

  /// The color the path will be drawn with.
  final Color color;

  /// The stroke width the path will be drawn with.
  final double strokeWidth;

  final bool indoorMode;

  /// Creates a [FreeStyleDrawable] to draw [path].
  ///
  /// The path will be drawn with the passed [color] and [strokeWidth] if provided.
  FreeStyleDrawable({
    required this.path,
    this.color = Colors.black,
    this.strokeWidth = 1,
    this.indoorMode = false,
    bool hidden = false,
  })  :
        // An empty path cannot be drawn, so it is an invalid argument.
        assert(path.isNotEmpty, 'The path cannot be an empty list'),

        // The line cannot have a non-positive stroke width.
        assert(strokeWidth > 0,
            'The stroke width cannot be less than or equal to 0'),
        super(hidden: hidden);

  /// Creates a copy of this but with the given fields replaced with the new values.
  FreeStyleDrawable copyWith(
      {bool? hidden,
      List<Offset>? path,
      Color? color,
      double? strokeWidth,
      bool? indoorMode}) {
    return FreeStyleDrawable(
      path: path ?? this.path,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      indoorMode: indoorMode ?? this.indoorMode,
      hidden: hidden ?? this.hidden,
    );
  }

  /// Draws the free-style [path] on the provided [canvas] of size [size].
  @override
  void draw(Canvas canvas, Size size) {
    // Create a UI path to draw
    final path = Path();

    // Start path from the first point
    path.moveTo(this.path[0].dx, this.path[0].dy);

    // Draw a line between each point on the free path
    this.path.sublist(1).forEach((point) {
      path.lineTo(point.dx, point.dy);
    });

    // Create the paint used to draw `_path`
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.green.withAlpha(175)
      ..strokeWidth = strokeWidth + 8;

    final outlinePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.black
      ..strokeWidth = strokeWidth + 2;

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white
      ..strokeWidth = strokeWidth;

    // Create the paint used to draw `_path`
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..strokeWidth = strokeWidth;

    if (indoorMode == false) {
      canvas.drawPath(path, outlinePaint);
      canvas.drawPath(path, outlinePaint2);
      canvas.drawPath(path, backgroundPaint);
      //canvas.drawPath(path, paint);
      canvas.drawPath(
        dashPath(
          path,
          dashArray: CircularIntervalList<double>(<double>[10.0, 12.5]),
        ),
        paint,
      );
    }
    if (indoorMode == true) {
      canvas.drawPath(path, outlinePaint2);
      canvas.drawPath(path, paint);
    }
  }

  /// Compares two [FreeStyleDrawable]s for equality.
  @override
  bool operator ==(Object other) {
    return other is FreeStyleDrawable &&
        super == other &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        const ListEquality().equals(other.path, path);
  }

  @override
  int get hashCode => hashValues(hidden, hashList(path), color, strokeWidth);
}
