import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/competitive_provider.dart';

class CompetitiveScreen extends ConsumerStatefulWidget {
  const CompetitiveScreen({super.key});

  @override
  ConsumerState<CompetitiveScreen> createState() =>
      _CompetitiveScreenState();
}

class _CompetitiveScreenState extends ConsumerState<CompetitiveScreen> {
  Timer? _countdownTimer;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    // Start countdown after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(competitiveProvider.notifier).startCountdown();
      _startCountdownTimer();
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final notifier = ref.read(competitiveProvider.notifier);
      final state = ref.read(competitiveProvider);
      if (state.phase == GamePhase.playing) {
        t.cancel();
        _startGameTimer();
      } else {
        notifier.tickCountdown();
      }
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final notifier = ref.read(competitiveProvider.notifier);
      final state = ref.read(competitiveProvider);
      if (state.phase == GamePhase.finished) {
        t.cancel();
      } else {
        notifier.tickTimer();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(competitiveProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Game content
          _buildGameBody(context, state),

          // Countdown overlay
          if (state.phase == GamePhase.countdown)
            _CountdownOverlay(value: state.countdownValue),

          // Finished overlay
          if (state.phase == GamePhase.finished)
            _FinishedOverlay(state: state, ref: ref),
        ],
      ),
    );
  }

  Widget _buildGameBody(BuildContext context, CompetitiveState state) {
    return Row(
      children: [
        // ─── Blue Team (Left) ──────────────────────
        Expanded(
          child: _TeamPanel(
            team: state.blueTeam,
            soal: state.blueSoal,
            isFlipped: false,
            onAnswer: (ans) =>
                ref.read(competitiveProvider.notifier).answerBlue(ans),
            timeLeft: state.timeLeft,
            totalTime: 60,
            phase: state.phase,
          ),
        ),

        // ─── Center Divider ──────────────────────
        _CenterDivider(timeLeft: state.timeLeft, phase: state.phase),

        // ─── Red Team (Right — flipped 180°) ────
        Expanded(
          child: Transform.rotate(
            angle: 3.14159, // π = 180 degrees
            child: _TeamPanel(
              team: state.redTeam,
              soal: state.redSoal,
              isFlipped: true,
              onAnswer: (ans) =>
                  ref.read(competitiveProvider.notifier).answerRed(ans),
              timeLeft: state.timeLeft,
              totalTime: 60,
              phase: state.phase,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Team Panel ───────────────────────────────────────────────
class _TeamPanel extends StatelessWidget {
  final TeamState team;
  final CompetitiveSoal soal;
  final bool isFlipped;
  final ValueChanged<int> onAnswer;
  final int timeLeft;
  final int totalTime;
  final GamePhase phase;

  const _TeamPanel({
    required this.team,
    required this.soal,
    required this.isFlipped,
    required this.onAnswer,
    required this.timeLeft,
    required this.totalTime,
    required this.phase,
  });

  Color get teamColor =>
      team.id == TeamId.blue ? AppColors.teamBlue : AppColors.teamRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            teamColor.withOpacity(0.15),
            teamColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Team header
          _TeamHeader(team: team, teamColor: teamColor),

          // Feedback banner
          if (team.lastFeedback.isNotEmpty)
            _FeedbackBanner(
              message: team.lastFeedback,
              isCorrect: team.isCorrect,
            ),

          // Question
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(soal.emoji, style: const TextStyle(fontSize: 60))
                      .animate(key: ValueKey('${team.id}_${team.correctCount + team.incorrectCount}'))
                      .scale(begin: const Offset(0, 0), curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: teamColor.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      soal.question,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: teamColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Answer choices
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: soal.choices.map((choice) {
                      return GestureDetector(
                        onTap: phase != GamePhase.playing
                            ? null
                            : () => onAnswer(choice),
                        child: Container(
                          decoration: BoxDecoration(
                            color: teamColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: teamColor.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$choice',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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

// ─── Team Header ──────────────────────────────────────────────
class _TeamHeader extends StatelessWidget {
  final TeamState team;
  final Color teamColor;
  const _TeamHeader({required this.team, required this.teamColor});

  @override
  Widget build(BuildContext context) {
    final isBlue = team.id == TeamId.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: teamColor,
      child: Row(
        children: [
          Text(
            isBlue ? '🔵 Tim Biru' : '🔴 Tim Merah',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '⭐ ${team.score}',
              style: TextStyle(
                color: teamColor,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feedback Banner ──────────────────────────────────────────
class _FeedbackBanner extends StatelessWidget {
  final String message;
  final bool isCorrect;
  const _FeedbackBanner(
      {required this.message, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: (isCorrect ? AppColors.correct : AppColors.incorrect)
          .withOpacity(0.2),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: isCorrect ? AppColors.correct : AppColors.incorrect,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
    ).animate(key: ValueKey(message)).fadeIn().slideY(begin: -0.5);
  }
}

// ─── Center Divider (Timer) ────────────────────────────────────
class _CenterDivider extends StatelessWidget {
  final int timeLeft;
  final GamePhase phase;
  const _CenterDivider({required this.timeLeft, required this.phase});

  @override
  Widget build(BuildContext context) {
    final isUrgent = timeLeft <= 10 && phase == GamePhase.playing;

    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.incorrect : AppColors.textDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              )),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.incorrect.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$timeLeft',
                  style: TextStyle(
                    color: isUrgent ? AppColors.incorrect : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
                Text(
                  'detik',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
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

// ─── Countdown Overlay ────────────────────────────────────────
class _CountdownOverlay extends StatelessWidget {
  final int value;
  const _CountdownOverlay({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value > 0 ? '$value' : 'MULAI!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 120,
                fontWeight: FontWeight.w900,
              ),
            )
                .animate(key: ValueKey(value))
                .scale(
                    begin: const Offset(1.5, 1.5),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.easeOut)
                .fadeIn(),
            const SizedBox(height: 16),
            const Text(
              'Bersiaplah!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Finished Overlay ─────────────────────────────────────────
class _FinishedOverlay extends StatelessWidget {
  final CompetitiveState state;
  final WidgetRef ref;
  const _FinishedOverlay({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final winner = state.winner;
    final isDraw = winner == null;

    return Container(
      color: Colors.black.withOpacity(0.82),
      child: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isDraw ? '🤝 Seri!' : (winner == TeamId.blue ? '🔵 Tim Biru Menang!' : '🔴 Tim Merah Menang!'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDraw
                      ? AppColors.textDark
                      : (winner == TeamId.blue
                          ? AppColors.teamBlue
                          : AppColors.teamRed),
                ),
                textAlign: TextAlign.center,
              ).animate().scale(curve: Curves.elasticOut),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScoreCard(
                    label: '🔵 Tim Biru',
                    score: state.blueTeam.score,
                    color: AppColors.teamBlue,
                    isWinner: winner == TeamId.blue,
                  ),
                  _ScoreCard(
                    label: '🔴 Tim Merah',
                    score: state.redTeam.score,
                    color: AppColors.teamRed,
                    isWinner: winner == TeamId.red,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(competitiveProvider.notifier).restart();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Main Lagi 🔄'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textMedium,
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
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final bool isWinner;
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: isWinner ? 3 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isWinner)
            const Text('🏆', style: TextStyle(fontSize: 32)),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score poin',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
