import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/competitive_questions.dart';

/// Soal Membaca kompetisi: susun suku kata dengan drag-and-drop ke kotak yang benar.
///
/// Layout (responsive via LayoutBuilder):
///   atas   : emoji + kata
///   tengah : kotak kosong target (DragTarget)
///   bawah  : tile suku kata tersedia (Draggable)
///
/// Saat semua kotak terisi dan urutan benar → [onComplete] dipanggil.
/// Saat salah → brief red feedback → reset.
class MembacaChallengeWidget extends StatefulWidget {
  final MembacaChallenge challenge;
  final Color teamColor;
  final bool isFlipped; // tim merah yang di-rotate 180°
  final VoidCallback onComplete;
  final VoidCallback onWrong;
  final int questionIndex; // untuk ValueKey reset

  const MembacaChallengeWidget({
    super.key,
    required this.challenge,
    required this.teamColor,
    required this.onComplete,
    required this.onWrong,
    this.isFlipped = false,
    this.questionIndex = 0,
  });

  @override
  State<MembacaChallengeWidget> createState() => _MembacaChallengeWidgetState();
}

class _MembacaChallengeWidgetState extends State<MembacaChallengeWidget> {
  late List<String?> _slots; // null = kosong
  late List<String> _available; // tile belum di-drop
  bool _showWrong = false;
  bool _showCorrect = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(MembacaChallengeWidget old) {
    super.didUpdateWidget(old);
    if (old.questionIndex != widget.questionIndex ||
        old.challenge.kata != widget.challenge.kata) {
      _reset();
    }
  }

  void _reset() {
    final n = widget.challenge.sukuKata.length;
    _slots = List.filled(n, null);
    _available = [...widget.challenge.sukuKata]..shuffle();
    _showWrong = false;
    _showCorrect = false;
  }

  // Drop tile ke slot[index]
  void _onDropToSlot(int index, String suku) {
    if (_showWrong || _showCorrect) return;
    setState(() {
      // Kembalikan tile yang ada ke pool
      if (_slots[index] != null) {
        _available.add(_slots[index]!);
      }
      // Ambil dari pool
      _available.remove(suku);
      _slots[index] = suku;

      // Cek jika semua slot terisi
      if (!_slots.contains(null)) {
        _checkAnswer();
      }
    });
  }

  // Kembalikan tile dari slot ke pool (tap)
  void _returnToPool(int index) {
    if (_showWrong || _showCorrect) return;
    if (_slots[index] == null) return;
    setState(() {
      _available.add(_slots[index]!);
      _slots[index] = null;
    });
  }

  void _checkAnswer() {
    final correct = widget.challenge.sukuKata;
    bool isCorrect = true;
    for (int i = 0; i < _slots.length; i++) {
      if (_slots[i] != correct[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      setState(() => _showCorrect = true);
      Future.delayed(const Duration(milliseconds: 400), widget.onComplete);
    } else {
      setState(() => _showWrong = true);
      widget.onWrong();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) setState(_reset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Emoji & Kata ──────────────────────────────────
          Column(
            children: [
              Text(
                widget.challenge.emoji,
                style: TextStyle(fontSize: h * 0.14),
              ).animate(key: ValueKey(widget.challenge.kata)).scale(
                    begin: const Offset(0.6, 0.6),
                    curve: Curves.elasticOut,
                  ),
              SizedBox(height: h * 0.01),
              Text(
                widget.challenge.kata,
                style: TextStyle(
                  fontSize: h * 0.09,
                  fontWeight: FontWeight.w900,
                  color: widget.teamColor,
                  letterSpacing: w * 0.015,
                ),
              ),
            ],
          ),

          // ── Instruksi ─────────────────────────────────────
          Text(
            'Susun suku kata yang benar! 👇',
            style: TextStyle(
              fontSize: h * 0.04,
              color: widget.teamColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),

          // ── Target Slots ──────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.challenge.sukuKata.length, (i) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.015),
                child: _buildSlot(i, w, h),
              );
            }),
          ),

          // ── Available Tiles ───────────────────────────────
          Wrap(
            spacing: w * 0.025,
            runSpacing: h * 0.02,
            alignment: WrapAlignment.center,
            children: _available
                .map((suku) => _buildTile(suku, w, h))
                .toList(),
          ),


        ],
      );
    });
  }

  Widget _buildSlot(int index, double w, double h) {
    final suku = _slots[index];
    final slotW = (w * 0.85 / widget.challenge.sukuKata.length).clamp(50.0, 120.0);
    final slotH = (h * 0.16).clamp(36.0, 72.0);

    return DragTarget<String>(
      onAcceptWithDetails: (d) => _onDropToSlot(index, d.data),
      builder: (ctx, candidates, rejected) {
        final highlight = candidates.isNotEmpty;
        Color bgColor;
        Color borderColor = widget.teamColor;

        if (_showCorrect && suku != null) {
          bgColor = Colors.green.withValues(alpha: 0.15);
          borderColor = Colors.green;
        } else if (_showWrong && suku != null) {
          bgColor = Colors.red.withValues(alpha: 0.15);
          borderColor = Colors.red;
        } else if (suku != null) {
          bgColor = widget.teamColor.withValues(alpha: 0.12);
        } else if (highlight) {
          bgColor = widget.teamColor.withValues(alpha: 0.2);
        } else {
          bgColor = Colors.white.withValues(alpha: 0.8);
        }

        return GestureDetector(
          onTap: () => _returnToPool(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: slotW,
            height: slotH,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(slotW * 0.15),
              border: Border.all(
                color: borderColor,
                width: highlight ? 2.5 : 2.0,
              ),
              boxShadow: highlight
                  ? [
                      BoxShadow(
                        color: widget.teamColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: suku == null
                  ? Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: widget.teamColor.withValues(alpha: 0.35),
                        fontSize: slotH * 0.38,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Text(
                      suku,
                      style: TextStyle(
                        fontSize: slotH * 0.42,
                        fontWeight: FontWeight.w900,
                        color: _showWrong
                            ? Colors.red
                            : (_showCorrect ? Colors.green : widget.teamColor),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTile(String suku, double w, double h) {
    final tileW = (w * 0.85 / widget.challenge.sukuKata.length).clamp(50.0, 120.0);
    final tileH = (h * 0.14).clamp(32.0, 64.0);

    final tileContent = Container(
      width: tileW,
      height: tileH,
      decoration: BoxDecoration(
        color: widget.teamColor,
        borderRadius: BorderRadius.circular(tileW * 0.15),
        boxShadow: [
          BoxShadow(
            color: widget.teamColor.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          suku,
          style: TextStyle(
            fontSize: tileH * 0.42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );

    // Feedback widget rotated jika tim merah (isFlipped)
    final feedbackWidget = Transform.rotate(
      angle: widget.isFlipped ? math.pi : 0,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(tileW * 0.15),
        color: widget.teamColor,
        child: SizedBox(
          width: tileW,
          height: tileH,
          child: Center(
            child: Text(
              suku,
              style: TextStyle(
                fontSize: tileH * 0.42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );

    return Draggable<String>(
      data: suku,
      feedback: feedbackWidget,
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: tileContent,
      ),
      child: tileContent,
    );
  }
}
