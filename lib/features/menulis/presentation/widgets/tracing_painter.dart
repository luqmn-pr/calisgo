import 'package:flutter/material.dart';
import '../../domain/menulis_provider.dart';
import '../../../../core/theme/app_theme.dart';

/// CustomPainter untuk tracing canvas
/// Menggunakan gaya penulisan seperti di halaman "Bertarung" (Competitive).
class TracingPainter extends CustomPainter {
  final MenulisState state;
  final Size size;

  TracingPainter({required this.state, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    _drawBackgroundCharacter(canvas, canvasSize);
    _drawGhostPaths(canvas, canvasSize);
    _drawCompletedStrokes(canvas, canvasSize);
    _drawCurrentPath(canvas, canvasSize);
    _drawCheckpoints(canvas, canvasSize);
  }

  // ─── 1. Karakter Latar (Transparan) ─────────────────────────
  void _drawBackgroundCharacter(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: state.currentLetter.character,
        style: TextStyle(
          fontSize: size.height * 0.75,
          color: AppColors.menulisColor.withValues(alpha: 0.06),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  // ─── 2. Ghost paths (Garis putus-putus panduan) ─────────────
  void _drawGhostPaths(Canvas canvas, Size size) {
    final letter = state.currentLetter;

    for (int si = 0; si < letter.strokes.length; si++) {
      final isCurrentOrFuture = si >= state.currentStrokeIndex;
      if (!isCurrentOrFuture) continue;

      final stroke = letter.strokes[si];

      final paint = Paint()
        ..color = AppColors.menulisColor.withValues(alpha: 0.3)
        ..strokeWidth = 10.0 // Dibuat lebih tebal
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      final points = stroke.map((o) => _scale(o, size)).toList();
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      _drawDashedPath(canvas, path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 8.0;
    const gapLength = 6.0;

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

  // ─── 3. Titik Kunci (Checkpoints dengan Nomor) ──────────────
  void _drawCheckpoints(Canvas canvas, Size size) {
    final letter = state.currentLetter;
    if (state.currentStrokeIndex >= letter.strokes.length) return;

    final checkpoints = letter.checkpoints[state.currentStrokeIndex];
    if (checkpoints.isEmpty) return;

    for (int i = 0; i < checkpoints.length; i++) {
      final pos = _scale(checkpoints[i], size);
      final r = size.width * 0.05; // radius relatif terhadap kanvas
      
      // Determine if this checkpoint has been passed by the user
      // For simplicity in UI, we just check distance from drawn path to this checkpoint
      bool isHit = false;
      const hitRadius = 30.0;
      for (final pt in state.currentPath) {
        final scaledPt = _scale(pt, size);
        if ((scaledPt - pos).distance < hitRadius) {
          isHit = true;
          break;
        }
      }

      // If tracing is complete or stroke is complete, mark all hit
      if (state.phase == TracingPhase.complete) isHit = true;

      // Find next target index
      int nextTargetIndex = 0;
      for (int j = 0; j < checkpoints.length; j++) {
        bool hitJ = false;
        final kp = _scale(checkpoints[j], size);
        for (final pt in state.currentPath) {
          if ((_scale(pt, size) - kp).distance < hitRadius) {
            hitJ = true;
            break;
          }
        }
        if (!hitJ) {
          nextTargetIndex = j;
          break;
        }
        if (j == checkpoints.length - 1) nextTargetIndex = checkpoints.length;
      }

      // Sembunyikan titik akhir pada huruf O atau angka 0 (loop tertutup)
      // jika jaraknya berdekatan dengan titik awal dan user belum mencapai titik ke-3 (index 2).
      if (i == checkpoints.length - 1 && i >= 2) {
        final dist = (checkpoints.last - checkpoints.first).distance;
        if (dist < 0.15) { // 15% dari kanvas (cukup dekat)
          if (nextTargetIndex < 2) {
            continue; // Jangan gambar titik ini dulu
          }
        }
      }

      // Shadow
      canvas.drawCircle(
        pos + const Offset(2, 3),
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );

      // Fill
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = isHit
              ? Colors.green
              : (i == nextTargetIndex
                  ? AppColors.menulisColor
                  : Colors.white.withValues(alpha: 0.9))
          ..style = PaintingStyle.fill,
      );

      // Border
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = isHit ? Colors.green : AppColors.menulisColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Nomor
      final numPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontSize: r * 1.1,
            fontWeight: FontWeight.w900,
            color: isHit ? Colors.white : (i == nextTargetIndex ? Colors.white : AppColors.menulisColor),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numPainter.paint(
        canvas,
        pos - Offset(numPainter.width / 2, numPainter.height / 2),
      );

      // Pulse ring untuk titik berikutnya
      if (i == nextTargetIndex && state.phase == TracingPhase.tracing) {
        canvas.drawCircle(
          pos,
          r + 5,
          Paint()
            ..color = AppColors.menulisColor.withValues(alpha: 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  // ─── 4. Completed strokes ──────────────────────────────
  void _drawCompletedStrokes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.correct.withValues(alpha: 0.85)
      ..strokeWidth = 18.0
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

  // ─── 5. Current user path ──────────────────────────────
  void _drawCurrentPath(Canvas canvas, Size size) {
    if (state.currentPath.isEmpty) return;

    final phase = state.phase;
    final Color pathColor;
    if (phase == TracingPhase.error) {
      pathColor = AppColors.incorrect;
    } else if (phase == TracingPhase.complete) {
      pathColor = AppColors.correct;
    } else {
      pathColor = AppColors.menulisColor;
    }

    final paint = Paint()
      ..color = pathColor.withValues(alpha: 0.85)
      ..strokeWidth = 18.0
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
  }

  Offset _scale(Offset normalized, Size size) {
    return Offset(normalized.dx * size.width, normalized.dy * size.height);
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}
