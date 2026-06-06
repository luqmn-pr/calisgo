import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/audio/tts_service.dart';
import '../../../core/audio/tts_provider.dart';
import '../data/membaca_data.dart';
import '../domain/membaca_provider.dart';
import 'widgets/membaca_drag_game.dart';

class MembacaScreen extends ConsumerWidget {
  const MembacaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membacaProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.membacaColor.withOpacity(0.25),
                  AppColors.membacaColor.withOpacity(0.05),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, ref, state),
                Expanded(
                  child: Builder(builder: (context) {
                    switch (state.mode) {
                      case MembacaMode.huruf:
                        return _HurufView(state: state, ref: ref);
                      case MembacaMode.kata:
                        return _KataView(state: state, ref: ref);
                      case MembacaMode.kalimat:
                        return _KalimatView(state: state, ref: ref);
                    }
                  }),
                ),
              ],
            ),
          ),

          // Status Feedback Overlay (Root Level for perfect centering)
          if (state.isCorrect || state.isError)
            Align(
              alignment: Alignment.center,
              child: Builder(builder: (context) {
                if (state.isCorrect) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.correct);
                    String textToSpeak = '';
                    if (state.mode == MembacaMode.huruf) {
                      textToSpeak = MembacaData.hurufAZ[state.currentIndex].huruf;
                    } else if (state.mode == MembacaMode.kata) {
                      textToSpeak = MembacaData.kataLatihan[state.currentIndex].kata;
                    } else if (state.mode == MembacaMode.kalimat) {
                      textToSpeak = MembacaData.kalimatLatihan[state.currentIndex].kalimatUtuh;
                    }
                    ProviderScope.containerOf(context).read(ttsServiceProvider).speak(textToSpeak);
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
                      (state.isCorrect
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(AppColors.correct, BlendMode.srcIn),
                              child: const Text('✔️', style: TextStyle(fontSize: 120)),
                            )
                          : const Text('❌', style: TextStyle(fontSize: 120)))
                          .animate()
                          .scale(curve: Curves.elasticOut)
                          .then(delay: state.isError ? 0.ms : null)
                          .shake(hz: state.isError ? 4 : 0),
                      SizedBox(height: context.sh(16)),
                      Text(
                        state.isCorrect ? 'Hebat!' : 'Salah',
                        style: GoogleFonts.nunito(
                          fontSize: context.fs(36),
                          color: state.isCorrect ? AppColors.correct : Colors.red,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
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

  Widget _buildTopBar(
      BuildContext context, WidgetRef ref, MembacaState state) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(20),
        vertical: context.sh(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
                      context.pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.membacaColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.membacaColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                  SizedBox(width: context.sw(20)),
                  Text('📖', style: TextStyle(fontSize: context.sw(40))),
                  SizedBox(width: context.sw(8)),
                ],
              ),
              _ScoreChip(score: state.score, color: AppColors.membacaColor),
            ],
          ),
          _ModeToggle(
            currentMode: state.mode,
            onChanged: (m) {
              ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
              ref.read(membacaProvider.notifier).setMode(m);
            },
          ),
        ],
      ),
    );
  }
}

// ── Mode Toggle ──────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final MembacaMode currentMode;
  final ValueChanged<MembacaMode> onChanged;
  const _ModeToggle({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _ToggleChip(
            label: 'Huruf',
            icon: '🔤',
            isActive: currentMode == MembacaMode.huruf,
            onTap: () => onChanged(MembacaMode.huruf),
          ),
          _ToggleChip(
            label: 'Kata',
            icon: '📝',
            isActive: currentMode == MembacaMode.kata,
            onTap: () => onChanged(MembacaMode.kata),
          ),
          _ToggleChip(
            label: 'Kalimat',
            icon: '📚',
            isActive: currentMode == MembacaMode.kalimat,
            onTap: () => onChanged(MembacaMode.kalimat),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label, icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label,
      required this.icon,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(12),
          vertical: context.sh(5),
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.membacaColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: context.sw(14))),
            SizedBox(width: context.sw(4)),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isActive ? Colors.white : AppColors.membacaColor,
                fontWeight: FontWeight.w700,
                fontSize: context.fs(13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Score chip ───────────────────────────────────────────────────
class _ScoreChip extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreChip({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: GoogleFonts.nunito(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navigation button ────────────────────────────────────────────
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

// ─── Huruf View ─────────────────────────────────────────────────
class _HurufView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;
  const _HurufView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final huruf = MembacaData.hurufAZ[state.currentIndex];

    return Row(
      children: [
        _ArrowBtn(
          icon: Icons.chevron_left_rounded,
          onTap: () {
            ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
            ref.read(membacaProvider.notifier).prevHuruf();
          },
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HurufCard(huruf: huruf, ref: ref)
                    .animate(key: ValueKey(state.currentIndex))
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 300.ms),
                SizedBox(width: context.sw(32)),
                _ContohCard(huruf: huruf)
                    .animate(key: ValueKey('c${state.currentIndex}'))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
        _ArrowBtn(
          icon: Icons.chevron_right_rounded,
          onTap: () {
            ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
            ref.read(membacaProvider.notifier).nextHuruf();
          },
        ),
      ],
    );
  }
}

class _HurufCard extends StatelessWidget {
  final HurufModel huruf;
  final WidgetRef ref;
  const _HurufCard({required this.huruf, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
        ProviderScope.containerOf(context).read(ttsServiceProvider).speak(huruf.huruf);
        ref.read(membacaProvider.notifier).toggleAnswer();
      },
      child: Container(
        width: context.sw(210),
        height: context.sh(240),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sw(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.membacaColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              huruf.huruf,
              style: GoogleFonts.nunito(
                fontSize: context.fs(110),
                fontWeight: FontWeight.w900,
                color: AppColors.membacaColor,
                height: 1,
              ),
            ),
            Text(
              huruf.hurufKecil,
              style: GoogleFonts.nunito(
                fontSize: context.fs(50),
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
                height: 1,
              ),
            ),
            SizedBox(height: context.sh(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sw(10),
                vertical: context.sh(3),
              ),
              decoration: BoxDecoration(
                color: AppColors.membacaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Tap untuk contoh',
                style: GoogleFonts.nunito(
                  fontSize: context.fs(10),
                  color: AppColors.textMedium,
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

class _ContohCard extends StatelessWidget {
  final HurufModel huruf;
  const _ContohCard({required this.huruf});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ProviderScope.containerOf(context).read(audioServiceProvider).playSound(SoundType.tap);
        ProviderScope.containerOf(context).read(ttsServiceProvider).speak(huruf.contohKata);
      },
      child: Container(
        width: context.sw(200),
        height: context.sh(230),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sw(20)),
          boxShadow: [
            BoxShadow(
              color: AppColors.membacaColor.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(huruf.emoji,
                style: TextStyle(fontSize: context.sw(75))),
            SizedBox(height: context.sh(12)),
            Text(
              huruf.contohKata,
              style: GoogleFonts.nunito(
                fontSize: context.fs(26),
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: context.sh(6)),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: huruf.huruf,
                  style: GoogleFonts.nunito(
                    color: AppColors.membacaColor,
                    fontWeight: FontWeight.w900,
                    fontSize: context.fs(18),
                  ),
                ),
                TextSpan(
                  text: huruf.contohKata.substring(1).toLowerCase(),
                  style: GoogleFonts.nunito(
                    color: AppColors.textMedium,
                    fontSize: context.fs(18),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.sw(12)),
        padding: EdgeInsets.all(context.sw(16)),
        decoration: BoxDecoration(
          color: AppColors.membacaColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.membacaColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.membacaColor,
          size: context.sw(64),
        ),
      ),
    );
  }
}

// ─── Kata View ──────────────────────────────────────────────────
class _KataView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;
  const _KataView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final kata = MembacaData.kataLatihan[state.currentIndex];

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, context.sh(-20)),
          child: Column(
            children: [
            Text(
              kata.emoji,
              style: TextStyle(fontSize: context.sw(48)),
            ).animate(key: ValueKey(state.currentIndex)).scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                ),
            SizedBox(height: context.sh(10)),
            Text(
              'Susun suku kata berikut!',
              style: GoogleFonts.nunito(
                fontSize: context.fs(16),
                color: AppColors.textMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: context.sh(16)),
            Expanded(
              child: MembacaGameWidget(
                correctSequence: kata.sukuKata,
                shuffledPieces: state.shuffledSukuKata,
                currentIndex: state.currentIndex,
                audioService: ProviderScope.containerOf(context, listen: false).read(audioServiceProvider),
                onAnswerSubmitted: (isCorrect) {
                  ref.read(membacaProvider.notifier).submitAnswer(isCorrect);
                },
              ),
            ),
          ],
        ),
      ),
        

          
        // Dot progress
        Positioned(
          bottom: context.sh(12),
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              MembacaData.kataLatihan.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: context.sw(3)),
                width: i == state.currentIndex ? 18 : 7,
                height: 7,
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
    );
  }
}

// ─── Kalimat View ────────────────────────────────────────────────
class _KalimatView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;
  const _KalimatView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final kalimat = MembacaData.kalimatLatihan[state.currentIndex];

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, context.sh(-20)),
          child: Column(
            children: [
            Text(
              kalimat.emoji,
              style: TextStyle(fontSize: context.sw(48)),
            ).animate(key: ValueKey(state.currentIndex)).scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  curve: Curves.elasticOut,
                ),
            SizedBox(height: context.sh(6)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Susun kata menjadi kalimat!',
                  style: GoogleFonts.nunito(
                    fontSize: context.fs(16),
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up_rounded, color: AppColors.membacaColor),
                  onPressed: () {
                    ProviderScope.containerOf(context, listen: false).read(ttsServiceProvider).speak(kalimat.kalimatUtuh);
                  },
                ),
              ],
            ),
            SizedBox(height: context.sh(10)),
            Expanded(
              child: MembacaGameWidget(
                correctSequence: kalimat.potonganKata,
                shuffledPieces: state.shuffledSukuKata,
                currentIndex: state.currentIndex,
                audioService: ProviderScope.containerOf(context, listen: false).read(audioServiceProvider),
                onAnswerSubmitted: (isCorrect) {
                  ref.read(membacaProvider.notifier).submitAnswer(isCorrect);
                },
              ),
            ),
            ],
          ),
        ),
          
        Positioned(
          bottom: context.sh(12),
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              MembacaData.kalimatLatihan.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: context.sw(3)),
                width: i == state.currentIndex ? 18 : 7,
                height: 7,
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
    );
  }
}
