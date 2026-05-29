import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _ObjectsPanel(state: state),
                      ),
                      Expanded(
                        flex: 4,
                        child: _AnswerPanel(state: state, ref: ref),
                      ),
                    ],
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
          _NavBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
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

class _ObjectsPanel extends StatelessWidget {
  final BerhitungState state;
  const _ObjectsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final soal = state.currentSoal;

    return Padding(
      padding: EdgeInsets.all(context.sw(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sw(20),
              vertical: context.sh(10),
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
                fontSize: context.fs(18),
                color: AppColors.berhitungColor,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate(key: ValueKey(state.currentIndex))
              .fadeIn()
              .slideY(begin: -0.2, end: 0),

          SizedBox(height: context.sh(18)),

          soal.type == SoalType.menghitung
              ? _CountingObjects(soal: soal, state: state)
              : _OperationObjects(soal: soal, state: state),
        ],
      ),
    );
  }
}

class _CountingObjects extends StatelessWidget {
  final BerhitungSoal soal;
  final BerhitungState state;
  const _CountingObjects({required this.soal, required this.state});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: context.sw(10),
      runSpacing: context.sh(8),
      children: List.generate(
        soal.angkaA,
        (i) => Text(soal.item.emoji,
                style: TextStyle(fontSize: context.sw(44)))
            .animate(
              delay: Duration(milliseconds: 60 * i),
              key: ValueKey('${state.currentIndex}_$i'),
            )
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
            ),
      ),
    );
  }
}

class _OperationObjects extends StatelessWidget {
  final BerhitungSoal soal;
  final BerhitungState state;
  const _OperationObjects({required this.soal, required this.state});

  @override
  Widget build(BuildContext context) {
    final operator = soal.type == SoalType.penjumlahan ? '+' : '-';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ObjectGroup(
          emoji: soal.item.emoji,
          count: soal.angkaA,
          color: soal.item.color,
          context: context,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sw(16)),
          child: Text(
            operator,
            style: GoogleFonts.nunito(
              fontSize: context.fs(36),
              color: AppColors.berhitungColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        _ObjectGroup(
          emoji: soal.item.emoji,
          count: soal.angkaB,
          color: soal.type == SoalType.pengurangan
              ? Colors.grey
              : soal.item.color,
          context: context,
          dimmed: soal.type == SoalType.pengurangan,
        ),
      ],
    );
  }
}

class _ObjectGroup extends StatelessWidget {
  final String emoji;
  final int count;
  final Color color;
  final BuildContext context;
  final bool dimmed;
  const _ObjectGroup({
    required this.emoji,
    required this.count,
    required this.color,
    required this.context,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext _) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: List.generate(
            count,
            (i) => Text(
              emoji,
              style: TextStyle(
                fontSize: context.sw(36),
                color: dimmed ? Colors.grey.withOpacity(0.5) : null,
              ),
            ),
          ),
        ),
        SizedBox(height: context.sh(6)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.sw(14),
            vertical: context.sh(4),
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: context.fs(18),
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerPanel extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _AnswerPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final choices = state.answerChoices;
    final isAnswered = state.phase != BerhitungPhase.answering;

    return Padding(
      padding: EdgeInsets.all(context.sw(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pilih jawabannya! 👇',
              style: GoogleFonts.nunito(
                fontSize: context.fs(15),
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: context.sh(8)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 2.2,
            children: choices.map((choice) {
              Color btnColor;
              if (!isAnswered) {
                btnColor = AppColors.berhitungColor;
              } else if (choice == state.currentSoal.jawaban) {
                btnColor = AppColors.correct;
              } else if (choice == state.selectedAnswer) {
                btnColor = AppColors.incorrect;
              } else {
                btnColor = Colors.grey.shade300;
              }

              return GestureDetector(
                onTap: isAnswered
                    ? null
                    : () => ref
                        .read(berhitungProvider.notifier)
                        .selectAnswer(choice),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isAnswered
                        ? []
                        : [
                            BoxShadow(
                              color:
                                  AppColors.berhitungColor.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      '$choice',
                      style: GoogleFonts.nunito(
                        fontSize: context.fs(28),
                        fontWeight: FontWeight.w900,
                        color: isAnswered &&
                                choice != state.currentSoal.jawaban
                            ? Colors.grey.shade500
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: context.sh(14)),
          if (isAnswered)
            Column(
              children: [
                Text(
                  state.phase == BerhitungPhase.correct
                      ? '🎉 Benar! +10 poin'
                      : '😅 Jawaban: ${state.currentSoal.jawaban}',
                  style: GoogleFonts.nunito(
                    fontSize: context.fs(15),
                    color: state.phase == BerhitungPhase.correct
                        ? AppColors.correct
                        : AppColors.incorrect,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn().scale(),
                SizedBox(height: context.sh(10)),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(berhitungProvider.notifier).nextSoal(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.berhitungColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.sw(20),
                      vertical: context.sh(8),
                    ),
                  ),
                  child: Text(
                    'Soal Berikutnya →',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
        ],
      ),)
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
                  const Text('🏆', style: TextStyle(fontSize: 64))
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
                        onPressed: () =>
                            ref.read(berhitungProvider.notifier).restart(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.berhitungColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Ulangi 🔄'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => context.go('/'),
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
