import 'dart:async';
import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/theme/app_theme.dart';
import '../data/competitive_questions.dart';
import '../domain/competitive_provider.dart';
import 'widgets/berhitung_drag_game.dart';
import 'widgets/membaca_challenge_widget.dart';
import 'widgets/menulis_challenge_widget.dart';

// ─── AppColors helpers ────────────────────────────────────────
extension _Colors on AppColors {
  static Color get teamBlue => const Color(0xFF1565C0);
  static Color get teamRed => const Color(0xFFC62828);
}

// ─── Main Screen ──────────────────────────────────────────────
class CompetitiveScreen extends ConsumerStatefulWidget {
  const CompetitiveScreen({super.key});

  @override
  ConsumerState<CompetitiveScreen> createState() => _CompetitiveScreenState();
}

class _CompetitiveScreenState extends ConsumerState<CompetitiveScreen> {
  Timer? _countdownTimer;
  Timer? _gameTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(competitiveProvider.notifier).startCountdown();
      _startCountdown();
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final s = ref.read(competitiveProvider);
      if (s.phase != GamePhase.countdown) {
        t.cancel();
        _startGameTimer();
      } else {
        ref.read(competitiveProvider.notifier).tickCountdown();
      }
    });
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final s = ref.read(competitiveProvider);
      if (s.phase == GamePhase.finished) {
        t.cancel();
      } else if (s.phase != GamePhase.countdown) {
        ref.read(competitiveProvider.notifier).tickTimer();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final sw = constraints.maxWidth;
          final sh = constraints.maxHeight;
          return Stack(
            children: [
              _GameBody(state: state, sw: sw, sh: sh),
              if (state.phase == GamePhase.countdown)
                _CountdownOverlay(value: state.countdownValue, sw: sw, sh: sh),
              if (state.phase == GamePhase.finished)
                _ResultOverlay(state: state, ref: ref, sw: sw, sh: sh),
            ],
          );
        },
      ),
    );
  }
}

// ─── Game Body ────────────────────────────────────────────────
class _GameBody extends ConsumerWidget {
  final CompetitiveState state;
  final double sw, sh;
  const _GameBody({required this.state, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dividerW = sw * 0.065;

    return Row(
      children: [
        Expanded(
          child: _TeamPanel(
            state: state,
            isBlue: true,
            sw: (sw - dividerW) / 2,
            sh: sh,
          ),
        ),
        _CenterDivider(state: state, dividerW: dividerW, sh: sh),
        Expanded(
          child: Transform.rotate(
            angle: math.pi,
            child: _TeamPanel(
              state: state,
              isBlue: false,
              sw: (sw - dividerW) / 2,
              sh: sh,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Team Panel ───────────────────────────────────────────────
/// Per-team stateful panel. Masing-masing tim punya overlay fase sendiri
/// sehingga player yang sudah maju lebih dulu tidak terganggu saat
/// lawannya baru pindah fase.
class _TeamPanel extends ConsumerStatefulWidget {
  final CompetitiveState state;
  final bool isBlue;
  final double sw, sh;

  const _TeamPanel({
    required this.state,
    required this.isBlue,
    required this.sw,
    required this.sh,
  });

  @override
  ConsumerState<_TeamPanel> createState() => _TeamPanelState();
}

class _TeamPanelState extends ConsumerState<_TeamPanel> {
  bool _showPhaseTransition = false;
  String _transitionLabel = '';
  GamePhase? _prevActivePhase;

  Color get teamColor => widget.isBlue ? _Colors.teamBlue : _Colors.teamRed;

  TeamState get team =>
      widget.isBlue ? widget.state.blueTeam : widget.state.redTeam;

  String _phaseLabel(GamePhase p) => switch (p) {
    GamePhase.membaca => '📖 Fase Membaca',
    GamePhase.menulis => '✏️ Fase Menulis',
    GamePhase.berhitung => '🔢 Fase Berhitung',
    GamePhase.finished => '🏆 Selesai!',
    _ => '',
  };

  String _phaseIcon(GamePhase p) => switch (p) {
    GamePhase.membaca => '📖',
    GamePhase.menulis => '✏️',
    GamePhase.berhitung => '🔢',
    GamePhase.finished => '🏆',
    _ => '🎮',
  };

  @override
  void didUpdateWidget(_TeamPanel old) {
    super.didUpdateWidget(old);
    final currentPhase = team.activePhase;
    // Deteksi perubahan fase HANYA untuk tim ini
    if (_prevActivePhase != null &&
        _prevActivePhase != currentPhase &&
        currentPhase != GamePhase.countdown) {
      final label = _phaseLabel(currentPhase);
      if (label.isNotEmpty) {
        setState(() {
          _showPhaseTransition = true;
          _transitionLabel = label;
        });
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) setState(() => _showPhaseTransition = false);
        });
      }
    }
    _prevActivePhase = currentPhase;
  }

  @override
  Widget build(BuildContext context) {
    final t = team;
    final headerH = widget.sh * 0.1;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            teamColor.withValues(alpha: 0.1),
            teamColor.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Stack(
        children: [
          // ── Main content ─────────────────────────────────────
          Column(
            children: [
              // Header
              _TeamHeader(
                team: t,
                teamColor: teamColor,
                headerH: headerH,
                phaseIcon: _phaseIcon(t.activePhase),
              ),

              // Feedback Banner
              if (t.lastFeedback.isNotEmpty)
                _FeedbackBanner(team: t, teamColor: teamColor, sh: widget.sh),

              // Challenge
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(widget.sw * 0.025),
                  child: _buildChallenge(context, t),
                ),
              ),
            ],
          ),

          // ── Per-team phase transition overlay ─────────────────
          if (_showPhaseTransition)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showPhaseTransition ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.78),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Fase Berikutnya',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: (widget.sh * 0.025).clamp(10.0, 15.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: widget.sh * 0.01),
                      Text(
                        _transitionLabel,
                        style: TextStyle(
                          color: teamColor,
                          fontSize: (widget.sh * 0.075).clamp(22.0, 44.0),
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate().scale(curve: Curves.elasticOut).fadeIn(),
                      SizedBox(height: widget.sh * 0.01),
                      Text(
                        '60 detik • 5 soal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: (widget.sh * 0.02).clamp(9.0, 13.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallenge(BuildContext context, TeamState t) {
    if (t.activePhase == GamePhase.finished) {
      return _DoneWidget(teamColor: teamColor, sh: widget.sh);
    }

    final challenge = widget.state.currentChallengeFor(t);
    final qi = t.questionIndex;

    // ── Membaca: drag suku kata ──────────────────────────────
    if (t.activePhase == GamePhase.membaca && challenge is MembacaChallenge) {
      return MembacaChallengeWidget(
        key: ValueKey('membaca_${widget.isBlue}_$qi'),
        challenge: challenge,
        teamColor: teamColor,
        isFlipped: !widget.isBlue,
        questionIndex: qi,
        onComplete: () => widget.isBlue
            ? ref.read(competitiveProvider.notifier).completeBlue()
            : ref.read(competitiveProvider.notifier).completeRed(),
      );
    }

    // ── Menulis: gambar bebas ────────────────────────────────
    if (t.activePhase == GamePhase.menulis && challenge is MenulisChallenge) {
      return MenulisChallengeWidget(
        key: ValueKey('menulis_${widget.isBlue}_$qi'),
        challenge: challenge,
        teamColor: teamColor,
        questionIndex: qi,
        onComplete: () => widget.isBlue
            ? ref.read(competitiveProvider.notifier).completeBlue()
            : ref.read(competitiveProvider.notifier).completeRed(),
      );
    }

    // ── Berhitung: Flame drag-drop ───────────────────────────
    if (t.activePhase == GamePhase.berhitung &&
        challenge is BerhitungChallenge) {
      return _BerhitungPanel(
        key: ValueKey('berhitung_${widget.isBlue}_$qi'),
        challenge: challenge,
        teamColor: teamColor,
        isFlipped: !widget.isBlue,
        questionIndex: qi,
        onComplete: () => widget.isBlue
            ? ref.read(competitiveProvider.notifier).completeBlue()
            : ref.read(competitiveProvider.notifier).completeRed(),
      );
    }

    return const SizedBox.shrink();
  }
}

// ─── Team Header ──────────────────────────────────────────────
class _TeamHeader extends StatelessWidget {
  final TeamState team;
  final Color teamColor;
  final double headerH;
  final String phaseIcon;

  const _TeamHeader({
    required this.team,
    required this.teamColor,
    required this.headerH,
    required this.phaseIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isBlue = team.id == TeamId.blue;
    final fs = (headerH * 0.3).clamp(10.0, 15.0);

    return Container(
      height: headerH,
      padding: EdgeInsets.symmetric(horizontal: headerH * 0.3),
      child: Row(
        children: [
          Text(
            isBlue ? '🔵 Tim Biru' : '🔴 Tim Merah',
            style: TextStyle(
              color: teamColor,
              fontWeight: FontWeight.w900,
              fontSize: fs,
            ),
          ),
          const SizedBox(width: 6),
          Text(phaseIcon, style: TextStyle(fontSize: fs)),
          const Spacer(),
          _Chip(
            label: '${team.questionIndex}/5',
            bg: Colors.white,
            fg: teamColor,
            fs: fs * 0.9,
          ),
          const SizedBox(width: 6),
          _Chip(
            label: '⭐ ${team.totalScore}',
            bg: Colors.white,
            fg: teamColor,
            fs: fs * 0.9,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final double fs;

  const _Chip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.fs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: fs),
      ),
    );
  }
}

// ─── Feedback Banner ──────────────────────────────────────────
class _FeedbackBanner extends StatelessWidget {
  final TeamState team;
  final Color teamColor;
  final double sh;

  const _FeedbackBanner({
    required this.team,
    required this.teamColor,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    final isOk = team.lastIsCorrect;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: sh * 0.008),
        color: (isOk ? AppColors.correct : AppColors.incorrect).withValues(
          alpha: 0.18,
        ),
        child: Center(
          child: Text(
            team.lastFeedback,
            style: TextStyle(
              fontSize: (sh * 0.025).clamp(10.0, 14.0),
              fontWeight: FontWeight.w800,
              color: isOk ? AppColors.correct : AppColors.incorrect,
            ),
          ),
        ),
      ),
    ).animate(key: ValueKey(team.lastFeedback)).fadeIn().slideY(begin: -0.4);
  }
}

// ─── Berhitung Panel ──────────────────────────────────────────
class _BerhitungPanel extends StatefulWidget {
  final BerhitungChallenge challenge;
  final Color teamColor;
  final bool isFlipped;
  final int questionIndex;
  final VoidCallback onComplete;

  const _BerhitungPanel({
    super.key,
    required this.challenge,
    required this.teamColor,
    required this.isFlipped,
    required this.questionIndex,
    required this.onComplete,
  });

  @override
  State<_BerhitungPanel> createState() => _BerhitungPanelState();
}

class _BerhitungPanelState extends State<_BerhitungPanel> {
  late BerhitungDragGame _game;
  bool _completed = false;
  int _currentCount = 0;
  bool _showWrong = false;
  bool _showCorrect = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void didUpdateWidget(_BerhitungPanel old) {
    super.didUpdateWidget(old);
    if (old.challenge.emoji != widget.challenge.emoji ||
        old.questionIndex != widget.questionIndex) {
      setState(() {
        _completed = false;
        _currentCount = 0;
        _showWrong = false;
        _showCorrect = false;
        _initGame();
      });
    }
  }

  void _initGame() {
    _game = BerhitungDragGame(
      emoji: widget.challenge.emoji,
      targetCount: widget.challenge.targetCount,
      totalSpawned: widget.challenge.totalSpawned,
      isFlipped: widget.isFlipped,
      onCountChanged: (count) {
        _currentCount = count;
      },
    );
  }

  void _onSubmit() {
    if (_completed || _showWrong || _showCorrect) return;
    if (_currentCount == widget.challenge.targetCount) {
      setState(() => _showCorrect = true);
      _completed = true;
      Future.delayed(const Duration(milliseconds: 600), widget.onComplete);
    } else {
      setState(() => _showWrong = true);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _showWrong = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth * 0.04,
                vertical: h * 0.03,
              ),
              decoration: BoxDecoration(
                color: _showCorrect
                    ? Colors.green.withValues(alpha: 0.15)
                    : (_showWrong
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showCorrect
                      ? Colors.green
                      : (_showWrong ? Colors.red : Colors.transparent),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.teamColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _showCorrect
                    ? '✅ Benar!'
                    : (_showWrong
                          ? '❌ Salah, hitung lagi!'
                          : widget.challenge.question),
                style: TextStyle(
                  fontSize: (h * 0.06).clamp(11.0, 16.0),
                  fontWeight: FontWeight.w800,
                  color: _showCorrect
                      ? Colors.green
                      : (_showWrong ? Colors.red : widget.teamColor),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: h * 0.02),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: GameWidget(game: _game),
              ),
            ),
            SizedBox(height: h * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.teamColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: h * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit Jawaban',
                  style: TextStyle(
                    fontSize: (h * 0.05).clamp(12.0, 16.0),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Center Divider ───────────────────────────────────────────
class _CenterDivider extends StatelessWidget {
  final CompetitiveState state;
  final double dividerW, sh;

  const _CenterDivider({
    required this.state,
    required this.dividerW,
    required this.sh,
  });

  String _phaseIcon(GamePhase p) => switch (p) {
        GamePhase.membaca => '📖',
        GamePhase.menulis => '✏️',
        GamePhase.berhitung => '🔢',
        GamePhase.finished => '🏆',
        _ => '🎮',
      };

  @override
  Widget build(BuildContext context) {
    final fs = (dividerW * 0.25).clamp(8.0, 14.0);
    final timerFs = (dividerW * 0.38).clamp(14.0, 22.0);

    Widget buildTimer(int timeLeft, bool isFinished) {
      final isUrgent = timeLeft <= 10 && !isFinished && state.phase != GamePhase.countdown;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: dividerW * 0.12,
          vertical: sh * 0.01,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isUrgent ? 0.25 : 0.1),
          borderRadius: BorderRadius.circular(8),
          border: isUrgent ? Border.all(color: Colors.red.shade400, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isUrgent ? Colors.red.shade300 : Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: isUrgent ? timerFs * 1.1 : timerFs,
              ),
              child: Text(isFinished ? '-' : '$timeLeft'),
            ),
            Text(
              'detik',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: fs * 0.65,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: dividerW,
      height: sh,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // BLUE TEAM SIDE
          Text(
            _phaseIcon(state.blueTeam.activePhase),
            style: TextStyle(fontSize: fs * 1.3),
          ),
          SizedBox(height: sh * 0.01),
          buildTimer(state.blueTeam.timeLeft, state.blueTeam.activePhase == GamePhase.finished),
          
          SizedBox(height: sh * 0.02),
          const Text(
            'VS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
          SizedBox(height: sh * 0.02),

          // RED TEAM SIDE (Rotated)
          Transform.rotate(
            angle: math.pi,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildTimer(state.redTeam.timeLeft, state.redTeam.activePhase == GamePhase.finished),
                SizedBox(height: sh * 0.01),
                Text(
                  _phaseIcon(state.redTeam.activePhase),
                  style: TextStyle(fontSize: fs * 1.3),
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
  final double sw, sh;

  const _CountdownOverlay({
    required this.value,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                  value > 0 ? '$value' : 'MULAI!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (sh * 0.25).clamp(60.0, 120.0),
                    fontWeight: FontWeight.w900,
                  ),
                )
                .animate(key: ValueKey(value))
                .scale(
                  begin: const Offset(1.5, 1.5),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOut,
                )
                .fadeIn(),
            SizedBox(height: sh * 0.02),
            Text(
              '📖 Membaca  →  ✏️ Menulis  →  🔢 Berhitung',
              style: TextStyle(
                color: Colors.white70,
                fontSize: (sh * 0.025).clamp(11.0, 16.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: sh * 0.01),
            Text(
              'Masing-masing 60 detik • 5 soal per fase',
              style: TextStyle(
                color: Colors.white54,
                fontSize: (sh * 0.02).clamp(9.0, 13.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Result Overlay ───────────────────────────────────────────
class _ResultOverlay extends StatelessWidget {
  final CompetitiveState state;
  final WidgetRef ref;
  final double sw, sh;

  const _ResultOverlay({
    required this.state,
    required this.ref,
    required this.sw,
    required this.sh,
  });

  @override
  Widget build(BuildContext context) {
    final winner = state.winner;
    final isDraw = winner == null;
    final containerW = (sw * 0.52).clamp(300.0, 480.0);
    final fs = (sh * 0.028).clamp(11.0, 16.0);

    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
            vertical: sh * 0.04,
          ),
          child: Container(
            width: containerW,
            padding: EdgeInsets.all(containerW * 0.07),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isDraw
                      ? '🤝 Seri!'
                      : (winner == TeamId.blue
                            ? '🔵 Tim Biru Menang!'
                            : '🔴 Tim Merah Menang!'),
                  style: TextStyle(
                    fontSize: (sh * 0.04).clamp(16.0, 26.0),
                    fontWeight: FontWeight.w900,
                    color: isDraw
                        ? Colors.black87
                        : (winner == TeamId.blue
                              ? _Colors.teamBlue
                              : _Colors.teamRed),
                  ),
                  textAlign: TextAlign.center,
                ).animate().scale(curve: Curves.elasticOut),
                SizedBox(height: containerW * 0.05),
                _PhaseScoreTable(state: state, fs: fs),
                SizedBox(height: containerW * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(competitiveProvider.notifier).restart();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref
                              .read(competitiveProvider.notifier)
                              .startCountdown();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: containerW * 0.08,
                          vertical: sh * 0.015,
                        ),
                      ),
                      icon: Icon(Icons.replay, size: fs),
                      label: Text('Main Lagi', style: TextStyle(fontSize: fs)),
                    ),
                    SizedBox(width: containerW * 0.04),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: containerW * 0.08,
                          vertical: sh * 0.015,
                        ),
                      ),
                      icon: Icon(Icons.home, size: fs),
                      label: Text('Menu', style: TextStyle(fontSize: fs)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseScoreTable extends StatelessWidget {
  final CompetitiveState state;
  final double fs;

  const _PhaseScoreTable({required this.state, required this.fs});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        '📖 Membaca',
        state.blueTeam.membacaCorrect,
        state.redTeam.membacaCorrect,
      ),
      (
        '✏️ Menulis',
        state.blueTeam.menulisCorrect,
        state.redTeam.menulisCorrect,
      ),
      (
        '🔢 Berhitung',
        state.blueTeam.berhitungCorrect,
        state.redTeam.berhitungCorrect,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '🔵 Tim Biru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _Colors.teamBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: fs,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                'Fase',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fs * 0.8, color: Colors.black45),
              ),
            ),
            Expanded(
              child: Text(
                '🔴 Tim Merah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _Colors.teamRed,
                  fontWeight: FontWeight.w800,
                  fontSize: fs,
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 12),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${r.$2}/5',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fs * 1.1,
                      fontWeight: FontWeight.w800,
                      color: r.$2 > r.$3 ? _Colors.teamBlue : Colors.black38,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    r.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fs * 0.85,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${r.$3}/5',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fs * 1.1,
                      fontWeight: FontWeight.w800,
                      color: r.$3 > r.$2 ? _Colors.teamRed : Colors.black38,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '${state.blueTeam.totalScore} pts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fs * 1.3,
                  fontWeight: FontWeight.w900,
                  color: _Colors.teamBlue,
                ),
              ),
            ),
            const SizedBox(
              width: 80,
              child: Text(
                'TOTAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${state.redTeam.totalScore} pts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fs * 1.3,
                  fontWeight: FontWeight.w900,
                  color: _Colors.teamRed,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Done Widget ──────────────────────────────────────────────
class _DoneWidget extends StatelessWidget {
  final Color teamColor;
  final double sh;

  const _DoneWidget({required this.teamColor, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🏆', style: TextStyle(fontSize: 52))
            .animate(onPlay: (c) => c.repeat())
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1))
            .then()
            .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9)),
        SizedBox(height: sh * 0.015),
        Text(
          'Semua Selesai!\n⏳ Menunggu lawan...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (sh * 0.028).clamp(12.0, 16.0),
            color: teamColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
