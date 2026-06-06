import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/menulis_provider.dart';
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
          child: Stack(
            children: [
              Column(
                children: [
                  // ─── Top Bar ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.menulisColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.menulisColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                          ),
                        ),
                        
                        // Title
                        Row(
                          children: [
                            const Text('✏️', style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 8),
                            Text(
                              'Menulis',
                              style: GoogleFonts.nunito(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.menulisColor,
                              ),
                            ),
                          ],
                        ),

                        // Score
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 24)),
                              const SizedBox(width: 8),
                              Text(
                                '${state.score}',
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.menulisColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Main Content Area ─────────────────────────────────────
                  Expanded(
                    child: Row(
                      children: [
                        // Left Sidebar (Categories & Retry)
                        _SidebarCategory(state: state, ref: ref),

                        // Center Tracing Canvas
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Column(
                              children: [
                                // Canvas
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: const ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(24)),
                                      child: TracingCanvas(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Stroke Progress
                                _StrokeProgress(state: state),
                              ],
                            ),
                          ),
                        ),

                        // Right Sidebar (Items Selector)
                        _LetterSelector(state: state, ref: ref),
                      ],
                    ),
                  ),
                ],
              ),

              // ─── Feedback Overlay ───────────────────────────────────────
              if (state.phase == TracingPhase.complete || state.phase == TracingPhase.error)
                _FeedbackOverlay(state: state),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Left Sidebar Category ──────────────────────────────────────────
class _SidebarCategory extends StatelessWidget {
  final MenulisState state;
  final WidgetRef ref;
  const _SidebarCategory({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Kategori Angka
          _CategoryItem(
            isActive: state.category == MenulisCategory.angka,
            text: '1',
            color: AppColors.primary,
            onTap: () {
              ref.read(menulisProvider.notifier).setCategory(MenulisCategory.angka);
            },
          ),
          
          // Kategori Huruf
          _CategoryItem(
            isActive: state.category == MenulisCategory.huruf,
            text: 'A',
            color: AppColors.menulisColor,
            onTap: () {
              ref.read(menulisProvider.notifier).setCategory(MenulisCategory.huruf);
            },
          ),
          
          const Divider(thickness: 2, indent: 20, endIndent: 20),

          // Ulangi Button
          GestureDetector(
            onTap: () => ref.read(menulisProvider.notifier).reset(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.amber.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final bool isActive;
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.isActive,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}


// ─── Stroke Progress ─────────────────────────────────────────
class _StrokeProgress extends StatelessWidget {
  final MenulisState state;
  const _StrokeProgress({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalStrokes = state.currentLetter.strokes.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Stroke: ',
          style: GoogleFonts.nunito(
            color: AppColors.textMedium, 
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        ...List.generate(
          totalStrokes,
          (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 36,
            height: 10,
            decoration: BoxDecoration(
              color: i < state.completedStrokes.length
                  ? AppColors.correct
                  : (i == state.currentStrokeIndex
                      ? AppColors.menulisColor
                      : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Right Letter Selector ──────────────────────────────────
class _LetterSelector extends StatelessWidget {
  final MenulisState state;
  final WidgetRef ref;
  const _LetterSelector({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: state.items.length,
          itemBuilder: (context, i) {
            final isActive = i == state.currentLetterIndex;
            final item = state.items[i];
            return GestureDetector(
              onTap: () {
                if (!isActive) {
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
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.menulisColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    item.displayLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 22,
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
      ),
    );
  }
}

// ─── Feedback Overlay ───────────────────────────────────────
class _FeedbackOverlay extends StatelessWidget {
  final MenulisState state;
  const _FeedbackOverlay({required this.state});

  @override
  Widget build(BuildContext context) {
    final isCorrect = state.phase == TracingPhase.complete;
    
    return Positioned.fill(
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final audio = ProviderScope.containerOf(context).read(audioServiceProvider);
            if (isCorrect) {
              audio.playSound(SoundType.correct);
            } else {
              audio.playSound(SoundType.incorrect);
            }
          });

          return GestureDetector(
            onTap: () {
              if (!isCorrect) {
                ProviderScope.containerOf(context).read(menulisProvider.notifier).clearStroke();
              }
            },
            child: Container(
              color: Colors.black.withOpacity(0.3),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (isCorrect
                      ? ColorFiltered(
                          colorFilter: ColorFilter.mode(AppColors.correct, BlendMode.srcIn),
                          child: const Text('✔️', style: TextStyle(fontSize: 120)),
                        )
                      : const Text('❌', style: TextStyle(fontSize: 120)))
                    .animate()
                    .scale(curve: Curves.elasticOut)
                    .then(delay: !isCorrect ? 0.ms : null)
                    .shake(hz: !isCorrect ? 4 : 0),
                const SizedBox(height: 16),
                Text(
                  isCorrect ? 'Hebat!' : 'Salah',
                  style: GoogleFonts.nunito(
                    fontSize: 48,
                    color: isCorrect ? AppColors.correct : Colors.red,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 200));
        },
      ),
    );
  }
}
