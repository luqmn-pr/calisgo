import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/competitive_questions.dart';

/// Soal Menulis kompetisi: gambar karakter bebas di layar.
///
/// Mekanik:
///   - Tampilkan outline karakter (transparan) + garis putus-putus antar key-points
///   - User menggambar bebas satu stroke di atas kanvas
///   - Saat jari diangkat: cek apakah jalur melewati semua key-points
///   - Berhasil → flash hijau → [onComplete]
///   - Gagal → flash merah → kanvas bersih → coba lagi
///
/// Pengecekan HANYA pada titik-titik kunci (tidak seluruh karakter).
class MenulisChallengeWidget extends StatefulWidget {
  final MenulisChallenge challenge;
  final Color teamColor;
  final VoidCallback onComplete;
  final VoidCallback onWrong;
  final int questionIndex;

  const MenulisChallengeWidget({
    super.key,
    required this.challenge,
    required this.teamColor,
    required this.onComplete,
    required this.onWrong,
    this.questionIndex = 0,
  });

  @override
  State<MenulisChallengeWidget> createState() => _MenulisChallengeWidgetState();
}

class _MenulisChallengeWidgetState extends State<MenulisChallengeWidget> {
  List<Offset> _path = [];
  bool _isDrawing = false;
  bool? _result; // null=idle, true=success, false=fail

  @override
  void didUpdateWidget(MenulisChallengeWidget old) {
    super.didUpdateWidget(old);
    if (old.challenge.character != widget.challenge.character) {
      setState(() {
        _path = [];
        _result = null;
        _isDrawing = false;
      });
    }
  }

  // ─── Gesture Handlers ────────────────────────────────────────
  void _onPanStart(DragStartDetails details, Size size) {
    if (_result == true) return; // sudah berhasil, tunggu callback
    setState(() {
      _path = [_norm(details.localPosition, size)];
      _isDrawing = true;
      _result = null;
    });
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!_isDrawing) return;
    setState(() {
      _path = [..._path, _norm(details.localPosition, size)];
    });
  }

  void _onPanEnd(Size size) {
    if (!_isDrawing) return;
    setState(() => _isDrawing = false);

    final allHit = _checkAllKeyPoints(_path, widget.challenge.keyPoints);

    setState(() => _result = allHit);

    if (allHit) {
      Future.delayed(const Duration(milliseconds: 700), widget.onComplete);
    } else {
      widget.onWrong();
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _path = [];
            _result = null;
          });
        }
      });
    }
  }

  /// Normalisasi posisi ke [0,1]
  Offset _norm(Offset pos, Size size) {
    final dx = (pos.dx / size.width).clamp(0.0, 1.0);
    final dy = (pos.dy / size.height).clamp(0.0, 1.0);
    return Offset(dx, dy);
  }

  /// Cek apakah path melewati semua key-points (radius 15% lebar)
  bool _checkAllKeyPoints(List<Offset> path, List<Offset> kps) {
    if (path.length < 3) return false;
    const radius = 0.15;
    for (final kp in kps) {
      bool hit = false;
      for (final pt in path) {
        if ((pt - kp).distance < radius) {
          hit = true;
          break;
        }
      }
      if (!hit) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      final canvasH = h * 0.75;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Instruksi ─────────────────────────────────────
          Text(
            'Gambar ${widget.challenge.displayLabel}!',
            style: TextStyle(
              fontSize: h * 0.045,
              color: widget.teamColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: h * 0.01),

          Text(
            'Lewati semua titik bernomor',
            style: TextStyle(
              fontSize: h * 0.033,
              color: widget.teamColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: h * 0.02),

          // ── Drawing Canvas ────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (d) => _onPanStart(d, Size(w, canvasH)),
            onPanUpdate: (d) => _onPanUpdate(d, Size(w, canvasH)),
            onPanEnd: (_) => _onPanEnd(Size(w, canvasH)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: w,
                height: canvasH,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _result == null
                        ? widget.teamColor.withValues(alpha: 0.3)
                        : (_result! ? Colors.green : Colors.red),
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: _MenulisPainter(
                    path: _path,
                    keyPoints: widget.challenge.keyPoints,
                    character: widget.challenge.character,
                    teamColor: widget.teamColor,
                    result: _result,
                    canvasSize: Size(w, canvasH),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: h * 0.02),


        ],
      );
    });
  }
}

// ─── CustomPainter ────────────────────────────────────────────
class _MenulisPainter extends CustomPainter {
  final List<Offset> path;
  final List<Offset> keyPoints;
  final String character;
  final Color teamColor;
  final bool? result; // null=idle, true=success, false=fail
  final Size canvasSize;

  _MenulisPainter({
    required this.path,
    required this.keyPoints,
    required this.character,
    required this.teamColor,
    required this.result,
    required this.canvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 1. Karakter latar (sangat transparan) ─────────────
    final tp = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: h * 0.75,
          color: teamColor.withValues(alpha: 0.06),
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));

    // ── 2. Garis putus-putus antar key-points (panduan) ──
    final dashPaint = Paint()
      ..color = teamColor.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < keyPoints.length - 1; i++) {
      final from = Offset(keyPoints[i].dx * w, keyPoints[i].dy * h);
      final to = Offset(keyPoints[i + 1].dx * w, keyPoints[i + 1].dy * h);
      _drawDashed(canvas, from, to, dashPaint);
    }

    // ── 3. Path yang digambar user ─────────────────────────
    if (path.length >= 2) {
      final pathColor = result == null
          ? teamColor
          : (result! ? Colors.green : Colors.red);

      final drawPaint = Paint()
        ..color = pathColor.withValues(alpha: result == null ? 0.85 : 1.0)
        ..strokeWidth = w * 0.035
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final flutterPath = Path()
        ..moveTo(path.first.dx * w, path.first.dy * h);
      for (int i = 1; i < path.length; i++) {
        flutterPath.lineTo(path[i].dx * w, path[i].dy * h);
      }
      canvas.drawPath(flutterPath, drawPaint);
    }

    // ── 4. Key-point circles ──────────────────────────────
    for (int i = 0; i < keyPoints.length; i++) {
      final pos = Offset(keyPoints[i].dx * w, keyPoints[i].dy * h);
      final r = w * 0.065;

      // Cek apakah titik ini sudah dilewati path
      final hit = result == true || _isHit(keyPoints[i]);

      // Shadow
      canvas.drawCircle(
        pos + Offset(2, 3),
        r,
        Paint()..color = Colors.black.withValues(alpha: 0.15),
      );

      // Fill
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = hit
              ? Colors.green
              : (i == _nextTargetIndex()
                  ? teamColor
                  : Colors.white.withValues(alpha: 0.9))
          ..style = PaintingStyle.fill,
      );

      // Border
      canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = hit ? Colors.green : teamColor
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
            color: hit ? Colors.white : (i == _nextTargetIndex() ? Colors.white : teamColor),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      numPainter.paint(
        canvas,
        pos - Offset(numPainter.width / 2, numPainter.height / 2),
      );

      // Pulse ring untuk titik berikutnya
      if (i == _nextTargetIndex() && result == null) {
        canvas.drawCircle(
          pos,
          r + 5,
          Paint()
            ..color = teamColor.withValues(alpha: 0.22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  bool _isHit(Offset kp) {
    const radius = 0.15;
    for (final pt in path) {
      if ((pt - kp).distance < radius) return true;
    }
    return false;
  }

  int _nextTargetIndex() {
    for (int i = 0; i < keyPoints.length; i++) {
      if (!_isHit(keyPoints[i])) return i;
    }
    return keyPoints.length; // semua terpenuhi
  }

  void _drawDashed(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dashLen = 5.0;
    const gapLen = 4.0;
    final dir = to - from;
    final total = dir.distance;
    if (total == 0) return;
    final unit = dir / total;
    double d = 0;
    bool draw = true;
    while (d < total) {
      final seg = draw
          ? (d + dashLen > total ? total - d : dashLen)
          : (d + gapLen > total ? total - d : gapLen);
      if (draw) {
        canvas.drawLine(from + unit * d, from + unit * (d + seg), paint);
      }
      d += seg;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(_MenulisPainter old) =>
      old.path != path || old.result != result;
}
