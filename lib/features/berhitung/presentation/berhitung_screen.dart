import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_sizes.dart';
import '../domain/berhitung_provider.dart';
import '../data/berhitung_data.dart';

class BerhitungScreen extends ConsumerWidget {
  const BerhitungScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(berhitungProvider);

    if (state.isFinished) return _FinishedView(state: state, ref: ref);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/module_bg.png', fit: BoxFit.cover),
          Container(color: AppColors.berhitungColor.withOpacity(0.12)),
          SafeArea(
            child: Column(
              children: [
                _TopBar(state: state, ref: ref),
                _QuestionBanner(state: state),
                Expanded(
                  child: _DragDropWorkspace(state: state, ref: ref),
                ),
              ],
            ),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(16),
        vertical: context.sh(8),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAB47BC), Color(0xFF6A1B9A)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.berhitungColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () {
            context.pop();
          }),
          SizedBox(width: context.sw(10)),
          Text('🔢', style: TextStyle(fontSize: context.sw(22))),
          SizedBox(width: context.sw(8)),
          Text(
            'Berhitung',
            style: GoogleFonts.nunito(
              fontSize: context.fs(18),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(width: context.sw(20)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(width: context.sw(10)),
          Text(
            '${state.currentIndex + 1}/${state.soalList.length}',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: context.fs(13),
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

class _DragDropWorkspace extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _DragDropWorkspace({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final soal = state.currentSoal;
    final isAnswered = state.phase != BerhitungPhase.answering;

    return Column(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // OUTSIDE AREA / TONG SAMPAH
              Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    if (details.data == 'inbox' && !isAnswered) {
                      ref.read(berhitungProvider.notifier).moveObjectToOutside();
                      ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      margin: EdgeInsets.all(context.sw(16)),
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty 
                          ? Colors.grey.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.withOpacity(0.8), width: 3, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Luar Kotak',
                              style: GoogleFonts.nunito(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: state.objectsOutside > 0 
                              ? Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: List.generate(
                                    state.objectsOutside,
                                    (i) => _buildDraggable(context, soal.item.emoji, 'outside', isAnswered),
                                  ),
                                )
                              : Icon(Icons.delete_outline, size: 60, color: Colors.grey.shade400),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // BOX AREA (Di Dalam Kotak)
              Expanded(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    if (details.data == 'outside' && !isAnswered) {
                      ref.read(berhitungProvider.notifier).moveObjectToBox();
                      ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      margin: EdgeInsets.all(context.sw(16)),
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty 
                          ? AppColors.berhitungColor.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.9),
                        border: Border.all(color: AppColors.berhitungColor, width: 5),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.berhitungColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Di Dalam Kotak',
                              style: GoogleFonts.nunito(
                                color: AppColors.berhitungColor,
                                fontWeight: FontWeight.w900,
                                fontSize: context.fs(16),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: List.generate(
                                  state.objectsInBox,
                                  (i) => _buildDraggable(context, soal.item.emoji, 'inbox', isAnswered),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // CHECK ANSWER BUTTON & RESULT
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.sh(20)),
          child: isAnswered 
            ? Column(
                children: [
                  Text(
                    state.phase == BerhitungPhase.correct
                        ? '🎉 Benar! Jawaban adalah ${state.currentSoal.jawaban}'
                        : '😅 Salah! Harusnya ada ${state.currentSoal.jawaban} di kotak',
                    style: GoogleFonts.nunito(
                      fontSize: context.fs(22),
                      color: state.phase == BerhitungPhase.correct
                          ? AppColors.correct
                          : AppColors.incorrect,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn().scale(),
                  SizedBox(height: context.sh(14)),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(berhitungProvider.notifier).nextSoal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.berhitungColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: EdgeInsets.symmetric(horizontal: context.sw(30), vertical: context.sh(14)),
                    ),
                    child: Text('Soal Berikutnya →', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: context.fs(18))),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: () {
                  final audio = ProviderScope.containerOf(context).read(audioServiceProvider);
                  ref.read(berhitungProvider.notifier).checkAnswer();
                  // Audio handled after checking phase
                  final newState = ref.read(berhitungProvider);
                  if (newState.phase == BerhitungPhase.correct) {
                    audio.playSound(SoundType.correct);
                  } else {
                    audio.playSound(SoundType.incorrect);
                  }
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
    );
  }

  Widget _buildDraggable(BuildContext context, String emoji, String data, bool isAnswered) {
    final emojiWidget = Text(emoji, style: TextStyle(fontSize: context.sw(40), decoration: TextDecoration.none));
    
    if (isAnswered) {
      return emojiWidget;
    }

    return Draggable<String>(
      data: data,
      feedback: Transform.scale(scale: 1.2, child: emojiWidget),
      childWhenDragging: Opacity(opacity: 0.3, child: emojiWidget),
      child: emojiWidget,
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
