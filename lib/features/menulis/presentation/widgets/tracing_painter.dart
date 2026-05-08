import 'package:flutter/material.dart';
import '../../domain/menulis_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// CustomPainter untuk tracing canvas
/// Menggambar:
/// 1. Ghost path (target stroke) — garis putus-putus abu
/// 2. Start indicator (dot hijau di titik awal)
/// 3. Completed strokes (hijau solid)
/// 4. Current user path (biru / warna aktif)
class TracingPainter extends CustomPainter {
  final MenulisState state;
  final Size size;

  TracingPainter({required this.state, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    _drawGhostPaths(canvas, canvasSize);
    _drawCompletedStrokes(canvas, canvasSize);
    _drawCurrentPath(canvas, canvasSize);
    _drawStartDot(canvas, canvasSize);
  }

  // ─── 1. Ghost (target) paths ────────────────────────────
  void _drawGhostPaths(Canvas canvas, Size size) {
    final letter = state.currentLetter;

    for (int si = 0; si < letter.strokes.length; si++) {
      final isCurrentOrFuture = si >= state.currentStrokeIndex;
      if (!isCurrentOrFuture) continue;

      final stroke = letter.strokes[si];
      final isCurrent = si == state.currentStrokeIndex;

      final paint = Paint()
        ..color = isCurrent
            ? Colors.grey.withOpacity(0.5)
            : Colors.grey.withOpacity(0.25)
        ..strokeWidth = isCurrent ? 24.0 : 18.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      // Dashed effect
      final path = Path();
      final points = stroke.map((o) => _scale(o, size)).toList();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      // Draw as dashed
      _drawDashedPath(canvas, path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 16.0;
    const gapLength = 10.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          final extracted = metric.extractPath(
            distance,
            (distance + len).clamp(0, metric.length),
          );
          canvas.drawPath(extracted, paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  // ─── 2. Completed strokes ──────────────────────────────
  void _drawCompletedStrokes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.correct.withOpacity(0.85)
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in state.completedStrokes) {
      if (stroke.isEmpty) continue;
      final points = stroke.map((o) => _scale(o, size)).toList();
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  // ─── 3. Current user path ──────────────────────────────
  void _drawCurrentPath(Canvas canvas, Size size) {
    if (state.currentPath.isEmpty) return;

    final phase = state.phase;
    final Color pathColor;
    if (phase == TracingPhase.error) {
      pathColor = AppColors.incorrect;
    } else if (phase == TracingPhase.complete) {
      pathColor = AppColors.correct;
    } else {
      pathColor = AppColors.primary;
    }

    final paint = Paint()
      ..color = pathColor
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final points =
        state.currentPath.map((o) => _scale(o, size)).toList();
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);

    // Pen tip dot
    final tipPaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.last, 12, tipPaint);
  }

  // ─── 4. Start dot ──────────────────────────────────────
  void _drawStartDot(Canvas canvas, Size size) {
    final letter = state.currentLetter;
    if (state.currentStrokeIndex >= letter.strokes.length) return;

    final stroke = letter.strokes[state.currentStrokeIndex];
    if (stroke.isEmpty) return;

    final startPoint = _scale(stroke.first, size);

    // Outer ring
    canvas.drawCircle(
      startPoint,
      18,
      Paint()
        ..color = AppColors.menulisColor.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    // Inner dot
    canvas.drawCircle(
      startPoint,
      10,
      Paint()
        ..color = AppColors.menulisColor
        ..style = PaintingStyle.fill,
    );

    // Label "Mulai"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Mulai',
        style: TextStyle(
          color: AppColors.menulisColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(startPoint.dx - textPainter.width / 2, startPoint.dy + 22),
    );
  }

  Offset _scale(Offset normalized, Size size) {
    return Offset(normalized.dx * size.width, normalized.dy * size.height);
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}
