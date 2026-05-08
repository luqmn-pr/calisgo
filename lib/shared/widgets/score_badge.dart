import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Badge skor untuk ditampilkan di header per tim
class ScoreBadge extends StatelessWidget {
  final int score;
  final Color? color;
  final double fontSize;

  const ScoreBadge({
    super.key,
    required this.score,
    this.color,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: TextStyle(
                color: badgeColor,
                fontWeight: FontWeight.w900,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
