import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Overlay confetti dan teks positif saat jawaban benar
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onComplete;

  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.isActive,
    this.onComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _confettiController.play();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive) ...[
          // Semi-transparent flash
          IgnorePointer(
            child: Container(
              color: AppColors.correct.withOpacity(0.1),
            ).animate().fadeIn(duration: 150.ms).then().fadeOut(duration: 300.ms),
          ),
          // Confetti from top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.correct,
                AppColors.primary,
                AppColors.membacaColor,
                AppColors.competitiveColor,
                AppColors.menulisColor,
              ],
              numberOfParticles: 30,
            ),
          ),
        ],
      ],
    );
  }
}
