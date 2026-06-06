import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/audio/tts_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_sizes.dart';
import '../domain/berhitung_provider.dart';
import '../data/berhitung_data.dart';
import 'widgets/berhitung_game_widget.dart';

class BerhitungScreen extends ConsumerStatefulWidget {
  const BerhitungScreen({super.key});

  @override
  ConsumerState<BerhitungScreen> createState() => _BerhitungScreenState();
}

class _BerhitungScreenState extends ConsumerState<BerhitungScreen> {
  String _getSpokenText(String text) {
    return text
        .replaceAll('+', 'tambah')
        .replaceAll('-', 'kurang')
        .replaceAll('=', 'sama dengan')
        .replaceAll('?', 'berapa');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(berhitungProvider);
      if (!state.isFinished) {
        ref.read(ttsServiceProvider).speak(_getSpokenText(state.currentSoal.pertanyaan));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BerhitungState>(berhitungProvider, (prev, next) {
      if (prev?.currentIndex != next.currentIndex && !next.isFinished) {
        ref.read(ttsServiceProvider).speak(_getSpokenText(next.currentSoal.pertanyaan));
      }
    });

    final state = ref.watch(berhitungProvider);

    if (state.isFinished) return _FinishedView(state: state, ref: ref);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.berhitungColor.withOpacity(0.2),
                  AppColors.berhitungColor.withOpacity(0.05),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _TopBar(state: state, ref: ref),
                _QuestionBanner(state: state),
                Expanded(
                  child: BerhitungGameWidget(
                    emoji: state.currentSoal.item.emoji,
                    totalSpawned: state.objectsInBox + state.objectsOutside,
                    initialInBox: state.objectsInBox,
                    currentIndex: state.currentIndex,
                    onCountChanged: (count) {
                      ref.read(berhitungProvider.notifier).setObjectsInBox(count);
                    },
                  ),
                ),
                // CHECK ANSWER BUTTON
                Padding(
                  padding: EdgeInsets.symmetric(vertical: context.sh(20)),
                  child: state.phase != BerhitungPhase.answering
                      ? const SizedBox.shrink()
                      : ElevatedButton(
                          onPressed: () {
                            ref.read(berhitungProvider.notifier).checkAnswer();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.berhitungColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: EdgeInsets.symmetric(horizontal: context.sw(40), vertical: context.sh(16)),
                            elevation: 6,
                          ),
                          child: Text('Cek Jawaban', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: context.fs(20))),
                        ),
                ),
              ],
            ),
          ),
          
          // Status Feedback Overlay
          if (state.phase == BerhitungPhase.correct || state.phase == BerhitungPhase.incorrect)
            Align(
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                final isCorrect = state.phase == BerhitungPhase.correct;
                if (isCorrect) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.correct);
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.incorrect);
                  });
                }
                return Container(
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
                    SizedBox(height: context.sh(16)),
                    Text(
                      isCorrect ? 'Hebat!' : 'Salah',
                      style: GoogleFonts.nunito(
                        fontSize: context.fs(36),
                        color: isCorrect ? AppColors.correct : Colors.red,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              }),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _TopBar({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(20),
        vertical: context.sh(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.berhitungColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.berhitungColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
            ),
          ),
          SizedBox(width: context.sw(20)),
          Text('🔢', style: TextStyle(fontSize: context.sw(40))),
          SizedBox(width: context.sw(8)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: AppColors.berhitungColor.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.berhitungColor),
                minHeight: 12,
              ),
            ),
          ),
          SizedBox(width: context.sw(10)),
          Text(
            '${state.currentIndex + 1}/${state.soalList.length}',
            style: GoogleFonts.nunito(
              color: AppColors.berhitungColor,
              fontWeight: FontWeight.w900,
              fontSize: context.fs(16),
            ),
          ),
          SizedBox(width: context.sw(16)),
          _ScoreChip(score: state.score),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final int score;
  const _ScoreChip({required this.score});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(14),
        vertical: context.sh(5),
      ),
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
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          SizedBox(width: context.sw(6)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: GoogleFonts.nunito(
                color: AppColors.berhitungColor,
                fontWeight: FontWeight.w900,
                fontSize: context.fs(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.sw(8)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: context.sw(18)),
      ),
    );
  }
}

class _QuestionBanner extends StatelessWidget {
  final BerhitungState state;
  const _QuestionBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final soal = state.currentSoal;

    return Padding(
      padding: EdgeInsets.all(context.sw(16)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(24),
          vertical: context.sh(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.berhitungColor.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          soal.pertanyaan,
          style: GoogleFonts.nunito(
            fontSize: context.fs(22),
            color: AppColors.berhitungColor,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ).animate(key: ValueKey(state.currentIndex)).fadeIn().slideY(begin: -0.2, end: 0),
    );
  }
}

class _FinishedView extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _FinishedView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final total = state.soalList.length;
    final pct = total == 0 ? 0 : (state.correctCount / total * 100).round();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/module_bg.png', fit: BoxFit.cover),
          Center(
            child: Container(
              padding: EdgeInsets.all(context.sw(40)),
              margin: EdgeInsets.symmetric(horizontal: context.sw(100)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.sw(28)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.berhitungColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(builder: (ctx) {
                    // Play celebration sound when finished view builds
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ProviderScope.containerOf(ctx).read(audioServiceProvider).playSound(SoundType.celebration);
                    });
                    return const Text('🏆', style: TextStyle(fontSize: 64));
                  })
                      .animate()
                      .scale(curve: Curves.elasticOut),
                  const SizedBox(height: 12),
                  Text(
                    'Selesai! 🎊',
                    style: GoogleFonts.nunito(
                      fontSize: context.fs(28),
                      color: AppColors.berhitungColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.correctCount}/${state.soalList.length} benar ($pct%)',
                    style: GoogleFonts.nunito(
                      fontSize: context.fs(16),
                      color: AppColors.textMedium,
                    ),
                  ),
                  Text(
                    'Skor: ${state.score} ⭐',
                    style: GoogleFonts.nunito(
                      fontSize: context.fs(20),
                      color: AppColors.berhitungColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(berhitungProvider.notifier).restart();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.berhitungColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Ulangi 🔄'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Menu 🏠'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
