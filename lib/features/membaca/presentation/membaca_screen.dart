import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/membaca_data.dart';
import '../domain/membaca_provider.dart';
import '../../../shared/widgets/celebration_overlay.dart';

class MembacaScreen extends ConsumerWidget {
  const MembacaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membacaProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context, ref, state),
              Expanded(
                child: state.mode == MembacaMode.huruf
                    ? _HurufView(state: state, ref: ref)
                    : _KataView(state: state, ref: ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, MembacaState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.membacaColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.membacaColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Text(
            '📖 Membaca',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),

          const Spacer(),

          // Mode Toggle
          _ModeToggle(
            currentMode: state.mode,
            onChanged: (mode) =>
                ref.read(membacaProvider.notifier).setMode(mode),
          ),

          const SizedBox(width: 16),

          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '${state.score}',
                  style: TextStyle(
                    color: AppColors.membacaColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mode Toggle ──────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final MembacaMode currentMode;
  final ValueChanged<MembacaMode> onChanged;

  const _ModeToggle({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            label: 'Huruf',
            isActive: currentMode == MembacaMode.huruf,
            onTap: () => onChanged(MembacaMode.huruf),
          ),
          _ToggleBtn(
            label: 'Kata',
            isActive: currentMode == MembacaMode.kata,
            onTap: () => onChanged(MembacaMode.kata),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.membacaColor : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ─── Huruf View ────────────────────────────────────────────────
class _HurufView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;

  const _HurufView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final huruf = MembacaData.hurufAZ[state.currentIndex];

    return Row(
      children: [
        // Navigation — Prev
        _NavArrow(
          icon: Icons.chevron_left,
          onTap: () => ref.read(membacaProvider.notifier).prevHuruf(),
        ),

        // Main card
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Huruf Card
                _HurufCard(huruf: huruf, state: state, ref: ref)
                    .animate(key: ValueKey(state.currentIndex))
                    .fadeIn(duration: 300.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                    ),

                const SizedBox(width: 40),

                // Contoh Kata Card
                _ContohKataCard(huruf: huruf),
              ],
            ),
          ),
        ),

        // Navigation — Next
        _NavArrow(
          icon: Icons.chevron_right,
          onTap: () => ref.read(membacaProvider.notifier).nextHuruf(),
        ),
      ],
    );
  }
}

class _HurufCard extends StatelessWidget {
  final HurufModel huruf;
  final MembacaState state;
  final WidgetRef ref;

  const _HurufCard({
    required this.huruf,
    required this.state,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(membacaProvider.notifier).toggleAnswer(),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.membacaColor.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              huruf.huruf,
              style: const TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                color: AppColors.membacaColor,
                height: 1,
              ),
            ),
            Text(
              huruf.hurufKecil,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
                height: 1,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.membacaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tap untuk contoh',
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContohKataCard extends StatelessWidget {
  final HurufModel huruf;
  const _ContohKataCard({required this.huruf});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.membacaColor.withOpacity(0.15),
            AppColors.membacaColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.membacaColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(huruf.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 10),
          Text(
            huruf.contohKata,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          // Highlight huruf awal
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: huruf.huruf,
                  style: const TextStyle(
                    color: AppColors.membacaColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: huruf.contohKata.substring(1).toLowerCase(),
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.membacaColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.membacaColor.withOpacity(0.3)),
        ),
        child: Icon(icon, color: AppColors.membacaColor, size: 28),
      ),
    );
  }
}

// ─── Kata View — Suku Kata Drag ────────────────────────────────
class _KataView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;

  const _KataView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final kata = MembacaData.kataLatihan[state.currentIndex];

    return CelebrationOverlay(
      isActive: state.isCorrect == true,
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emoji & target kata
                  Text(kata.emoji, style: const TextStyle(fontSize: 72))
                      .animate(key: ValueKey(state.currentIndex))
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        curve: Curves.elasticOut,
                      ),

                  const SizedBox(height: 16),

                  Text(
                    'Susun suku kata berikut!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Drop zone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(
                        kata.sukuKata.length,
                        (i) => _DropSlot(
                          content: i < state.arrangedSukuKata.length
                              ? state.arrangedSukuKata[i]
                              : null,
                          onRemove: i < state.arrangedSukuKata.length
                              ? () => ref
                                    .read(membacaProvider.notifier)
                                    .removeSukuKata(state.arrangedSukuKata[i])
                              : null,
                          isCorrect: state.isCorrect,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Source suku kata chips
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 16,
                    children: state.shuffledSukuKata.map((suku) {
                      final used = state.arrangedSukuKata.contains(suku);
                      return GestureDetector(
                        onTap: used
                            ? null
                            : () => ref
                                  .read(membacaProvider.notifier)
                                  .pickSukuKata(suku),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: used
                                ? Colors.grey.shade300
                                : AppColors.membacaColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: used
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.membacaColor.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Text(
                            suku,
                            style: TextStyle(
                              color: used ? Colors.grey.shade500 : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Result feedback
                  if (state.isCorrect == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          const Text(
                            '🎉',
                            style: TextStyle(fontSize: 48),
                          ).animate().scale(curve: Curves.elasticOut),
                          const SizedBox(height: 8),
                          Text(
                            'Hebat! ${kata.kata} ✓',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.correct,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                ref.read(membacaProvider.notifier).nextKata(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.membacaColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Kata Berikutnya →'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 60), // Space for progress indicator
                ],
              ),
            ),
          ),

          // Progress indicator
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                MembacaData.kataLatihan.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == state.currentIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == state.currentIndex
                        ? AppColors.membacaColor
                        : AppColors.membacaColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropSlot extends StatelessWidget {
  final String? content;
  final VoidCallback? onRemove;
  final bool isCorrect;

  const _DropSlot({this.content, this.onRemove, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 100,
        height: 70,
        decoration: BoxDecoration(
          color: content != null
              ? (isCorrect ? AppColors.correct : AppColors.primary)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: content != null
                ? Colors.transparent
                : AppColors.membacaColor.withOpacity(0.4),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: content != null
              ? [
                  BoxShadow(
                    color: (isCorrect ? AppColors.correct : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: content != null
              ? Text(
                  content!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                )
              : Text(
                  '?',
                  style: TextStyle(
                    color: AppColors.membacaColor.withOpacity(0.4),
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
        ),
      ),
    );
  }
}
