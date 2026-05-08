import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/berhitung_data.dart';
import '../domain/berhitung_provider.dart';

class BerhitungScreen extends ConsumerWidget {
  const BerhitungScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(berhitungProvider);

    if (state.isFinished) {
      return _FinishedView(state: state, ref: ref);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(state: state, ref: ref),
              Expanded(
                child: Row(
                  children: [
                    // Left: Visual objects
                    Expanded(flex: 5, child: _ObjectsPanel(state: state)),
                    // Right: Answer panel
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
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _TopBar({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.berhitungColor,
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
            '🔢 Berhitung',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 24),
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${state.currentIndex + 1}/${state.soalList.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 24),
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
                    color: AppColors.berhitungColor,
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

// ─── Objects Panel ────────────────────────────────────────────
class _ObjectsPanel extends StatelessWidget {
  final BerhitungState state;
  const _ObjectsPanel({required this.state});

  @override
  Widget build(BuildContext context) {
    final soal = state.currentSoal;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question text
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.berhitungColor.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  soal.pertanyaan,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.berhitungColor,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              .animate(key: ValueKey(state.currentIndex))
              .fadeIn()
              .slideY(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          // Visual objects grid
          if (soal.type == SoalType.menghitung)
            _CountingObjects(soal: soal, state: state)
          else
            _OperationObjects(soal: soal, state: state),
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
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        soal.angkaA,
        (i) => Text(soal.item.emoji, style: const TextStyle(fontSize: 52))
            .animate(
              delay: Duration(milliseconds: 50 * i),
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
        // Group A
        Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                soal.angkaA,
                (i) =>
                    Text(soal.item.emoji, style: const TextStyle(fontSize: 44)),
              ),
            ),
            const SizedBox(height: 8),
            _CountChip(count: soal.angkaA, color: soal.item.color),
          ],
        ),

        // Operator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            operator,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppColors.berhitungColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        // Group B
        Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                soal.angkaB,
                (i) => Text(
                  soal.item.emoji,
                  style: TextStyle(
                    fontSize: 44,
                    color: soal.type == SoalType.pengurangan
                        ? Colors.grey.withOpacity(0.5)
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _CountChip(
              count: soal.angkaB,
              color: soal.type == SoalType.pengurangan
                  ? Colors.grey
                  : soal.item.color,
            ),
          ],
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  final Color color;
  const _CountChip({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 20,
        ),
      ),
    );
  }
}

// ─── Answer Panel ─────────────────────────────────────────────
class _AnswerPanel extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _AnswerPanel({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final choices = state.answerChoices;
    final isAnswered = state.phase != BerhitungPhase.answering;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Jawabannya adalah...',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.textMedium),
            ),
            const SizedBox(height: 20),

            // MCQ Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
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
                                color: AppColors.berhitungColor.withOpacity(
                                  0.3,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        '$choice',
                        style: TextStyle(
                          color: isAnswered && btnColor == Colors.grey.shade300
                              ? Colors.grey.shade500
                              : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            if (isAnswered)
              Column(
                children: [
                  Text(
                    state.phase == BerhitungPhase.correct
                        ? '🎉 Benar! +10 poin'
                        : '😅 Jawaban: ${state.currentSoal.jawaban}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: state.phase == BerhitungPhase.correct
                          ? AppColors.correct
                          : AppColors.incorrect,
                      fontWeight: FontWeight.w900,
                    ),
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(berhitungProvider.notifier).nextSoal(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.berhitungColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Soal Berikutnya →',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Finished View ────────────────────────────────────────────
class _FinishedView extends StatelessWidget {
  final BerhitungState state;
  final WidgetRef ref;
  const _FinishedView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final pct = (state.correctCount / state.soalList.length * 100).round();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 80),
              ).animate().scale(curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                'Selesai!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.berhitungColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${state.correctCount}/${state.soalList.length} benar ($pct%)',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textMedium,
                ),
              ),
              Text(
                'Skor: ${state.score} poin ⭐',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.berhitungColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
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
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Menu Utama 🏠'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
