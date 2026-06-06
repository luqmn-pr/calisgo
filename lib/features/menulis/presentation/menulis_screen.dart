import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_provider.dart';

import '../../../core/audio/sound_generator.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/menulis_provider.dart';
import '../../competitive/data/competitive_questions.dart';
import '../../competitive/presentation/widgets/menulis_challenge_widget.dart';

import 'widgets/tracing_canvas.dart';

class MenulisScreen extends ConsumerWidget {
  const MenulisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(menulisProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ─── Left: Controls Panel ──────────────
              _ControlsPanel(state: state, ref: ref),

              // ─── Center: Tracing Canvas ────────────
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Feedback banner
                      _FeedbackBanner(state: state),
                      const SizedBox(height: 12),
                      // Canvas
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                      child: MenulisChallengeWidget(
                            challenge: MenulisChallenge(
                              character: state.currentLetter.character,
                              displayLabel: state.currentLetter.displayLabel,
                              keyPoints: state.currentLetter.checkpoints
                                  .expand((s) => s)
                                  .toList(),
                            ),
                            teamColor: AppColors.menulisColor,
                            onComplete: () {
                              ref.read(menulisProvider.notifier).addScoreAndNext();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ─── Right: Letter Selector ────────────
              _LetterSelector(state: state, ref: ref),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Controls Panel ───────────────────────────────────────────
class _ControlsPanel extends StatelessWidget {
  final MenulisState state;
  final WidgetRef ref;
  const _ControlsPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: AppColors.menulisColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.menulisColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Back button
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      '✏️\nMenulis',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),

                    const SizedBox(height: 20),

                    // Score
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 24)),
                          Text(
                            '${state.score}',
                            style: TextStyle(
                              color: AppColors.menulisColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Poin',
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action buttons
                    _ActionBtn(
                      icon: Icons.refresh,
                      label: 'Ulangi',
                      onTap: () {
                        ref.read(menulisProvider.notifier).reset();
                      },
                    ),
                    const SizedBox(height: 8),
                    _ActionBtn(
                      icon: Icons.skip_next,
                      label: 'Lewati',
                      onTap: () {
                        ref.read(menulisProvider.notifier).nextLetter();
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feedback Banner ──────────────────────────────────────────
class _FeedbackBanner extends StatelessWidget {
  final MenulisState state;
  const _FeedbackBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    // Kita tidak pakai feedback banner lagi karena MenulisChallengeWidget sudah 
    // memiliki UI feedback sendiri di dalamnya.
    return const SizedBox.shrink();
  }
}





// ─── Letter Selector Sidebar ──────────────────────────────────
class _LetterSelector extends StatelessWidget {
  final MenulisState state;
  final WidgetRef ref;
  const _LetterSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: state.items.length,
        itemBuilder: (context, i) {
          final isActive = i == state.currentLetterIndex;
          final item = state.items[i];
          return GestureDetector(
            onTap: () {
              if (!isActive) {
                // Navigate directly to selected letter
                final notifier = ref.read(menulisProvider.notifier);
                for (int j = 0; j < (i - state.currentLetterIndex).abs(); j++) {
                  if (i > state.currentLetterIndex) {
                    notifier.nextLetter();
                  } else {
                    notifier.prevLetter();
                  }
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin:
                  const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.menulisColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  item.displayLabel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isActive
                        ? Colors.white
                        : AppColors.textMedium,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
