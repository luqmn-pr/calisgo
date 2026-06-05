import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/competitive_questions.dart';

// ─── Enums ────────────────────────────────────────────────────
enum TeamId { blue, red }

/// Fase permainan — countdown, 3 fase aktif, dan selesai.
/// Setiap tim bisa berada di fase yang berbeda (salah satu bisa maju lebih cepat).
enum GamePhase { countdown, membaca, menulis, berhitung, finished }

// ─── Per-Team State ───────────────────────────────────────────
class TeamState {
  final TeamId id;
  final int totalScore;

  /// Fase aktif tim saat ini
  final GamePhase activePhase;

  /// Soal ke-berapa di dalam [activePhase] (0-indexed, max 4)
  final int questionIndex;

  /// Sisa waktu per fase (60 detik)
  final int timeLeft;

  // Statistik per fase (untuk tabel hasil)
  final int membacaCorrect;
  final int menulisCorrect;
  final int berhitungCorrect;

  final String lastFeedback;
  final bool lastIsCorrect;

  const TeamState({
    required this.id,
    this.totalScore = 0,
    this.activePhase = GamePhase.membaca,
    this.questionIndex = 0,
    this.timeLeft = 60,
    this.membacaCorrect = 0,
    this.menulisCorrect = 0,
    this.berhitungCorrect = 0,
    this.lastFeedback = '',
    this.lastIsCorrect = false,
  });

  TeamState copyWith({
    int? totalScore,
    GamePhase? activePhase,
    int? questionIndex,
    int? timeLeft,
    int? membacaCorrect,
    int? menulisCorrect,
    int? berhitungCorrect,
    String? lastFeedback,
    bool? lastIsCorrect,
  }) =>
      TeamState(
        id: id,
        totalScore: totalScore ?? this.totalScore,
        activePhase: activePhase ?? this.activePhase,
        questionIndex: questionIndex ?? this.questionIndex,
        timeLeft: timeLeft ?? this.timeLeft,
        membacaCorrect: membacaCorrect ?? this.membacaCorrect,
        menulisCorrect: menulisCorrect ?? this.menulisCorrect,
        berhitungCorrect: berhitungCorrect ?? this.berhitungCorrect,
        lastFeedback: lastFeedback ?? this.lastFeedback,
        lastIsCorrect: lastIsCorrect ?? this.lastIsCorrect,
      );
}

// ─── Global Game State ────────────────────────────────────────
class CompetitiveState {
  /// Global status: countdown -> playing -> finished
  final GamePhase phase;
  final int countdownValue;

  final TeamState blueTeam;
  final TeamState redTeam;

  final List<MembacaChallenge> membacaQ;
  final List<MenulisChallenge> menulisQ;
  final List<BerhitungChallenge> berhitungQ;

  const CompetitiveState({
    this.phase = GamePhase.countdown,
    this.countdownValue = 3,
    required this.blueTeam,
    required this.redTeam,
    this.membacaQ = const [],
    this.menulisQ = const [],
    this.berhitungQ = const [],
  });

  CompetitiveState copyWith({
    GamePhase? phase,
    int? countdownValue,
    TeamState? blueTeam,
    TeamState? redTeam,
  }) =>
      CompetitiveState(
        phase: phase ?? this.phase,
        countdownValue: countdownValue ?? this.countdownValue,
        blueTeam: blueTeam ?? this.blueTeam,
        redTeam: redTeam ?? this.redTeam,
        membacaQ: membacaQ,
        menulisQ: menulisQ,
        berhitungQ: berhitungQ,
      );

  // ─── Current challenge helpers ─────────────────────────────
  CompetitiveChallenge currentChallengeFor(TeamState team) {
    final qi = team.questionIndex.clamp(0, 4);
    switch (team.activePhase) {
      case GamePhase.membaca:
        return membacaQ[qi.clamp(0, membacaQ.length - 1)];
      case GamePhase.menulis:
        return menulisQ[qi.clamp(0, menulisQ.length - 1)];
      case GamePhase.berhitung:
        return berhitungQ[qi.clamp(0, berhitungQ.length - 1)];
      default:
        return membacaQ[0]; // fallback
    }
  }

  // ─── Winner ────────────────────────────────────────────────
  TeamId? get winner {
    if (phase != GamePhase.finished) return null;
    if (blueTeam.totalScore > redTeam.totalScore) return TeamId.blue;
    if (redTeam.totalScore > blueTeam.totalScore) return TeamId.red;
    return null; // seri
  }
}

// ─── Notifier ─────────────────────────────────────────────────
class CompetitiveNotifier extends StateNotifier<CompetitiveState> {
  static const int kQuestionsPerPhase = 5;
  static const int kTimerSeconds = 60;

  CompetitiveNotifier()
      : super(CompetitiveState(
          blueTeam: const TeamState(id: TeamId.blue, timeLeft: kTimerSeconds),
          redTeam: const TeamState(id: TeamId.red, timeLeft: kTimerSeconds),
          membacaQ: CompetitiveQuestions.membacaList..shuffle(),
          menulisQ: CompetitiveQuestions.menulisList..shuffle(),
          berhitungQ: CompetitiveQuestions.berhitungList..shuffle(),
        ));

  // ─── Countdown ──────────────────────────────────────────────
  void startCountdown() {
    state = state.copyWith(phase: GamePhase.countdown, countdownValue: 3);
  }

  void tickCountdown() {
    if (state.countdownValue > 1) {
      state = state.copyWith(countdownValue: state.countdownValue - 1);
    } else {
      state = state.copyWith(phase: GamePhase.membaca); // main game starts
    }
  }

  // ─── Game Timer ──────────────────────────────────────────────
  void tickTimer() {
    if (state.phase == GamePhase.countdown || state.phase == GamePhase.finished) {
      return;
    }

    TeamState newBlue = state.blueTeam;
    TeamState newRed = state.redTeam;

    newBlue = _tickTeam(newBlue);
    newRed = _tickTeam(newRed);

    GamePhase newGlobalPhase = state.phase;
    if (newBlue.activePhase == GamePhase.finished && newRed.activePhase == GamePhase.finished) {
      newGlobalPhase = GamePhase.finished;
    }

    state = state.copyWith(
      phase: newGlobalPhase,
      blueTeam: newBlue,
      redTeam: newRed,
    );
  }

  TeamState _tickTeam(TeamState team) {
    if (team.activePhase == GamePhase.finished) return team;

    if (team.timeLeft > 1) {
      return team.copyWith(timeLeft: team.timeLeft - 1);
    } else {
      return _forceAdvance(team);
    }
  }

  /// Paksa tim maju (saat waktu habis, tanpa mendapat poin soal ini)
  TeamState _forceAdvance(TeamState team) {
    final next = _nextPhase(team.activePhase);
    return team.copyWith(
      activePhase: next,
      questionIndex: 0,
      timeLeft: kTimerSeconds,
      lastFeedback: '⏰ Waktu Habis!',
      lastIsCorrect: false,
    );
  }

  // ─── Complete Challenge (selalu dipanggil saat benar) ────────
  void completeBlue() => _completeForTeam(isBlue: true);
  void completeRed() => _completeForTeam(isBlue: false);

  void _completeForTeam({required bool isBlue}) {
    final team = isBlue ? state.blueTeam : state.redTeam;

    // Guard: jika tim sudah selesai semua fase
    if (team.activePhase == GamePhase.finished) return;

    // ── Hitung score ──────────────────────────────────────────
    // Base: 10 poin per soal
    // Bonus kecepatan: max 10 poin extra (proporsional sisa waktu)
    final timeBonus = (team.timeLeft / kTimerSeconds * 10).round();
    final scoreGain = 10 + timeBonus;

    // ── Update statistik per fase ─────────────────────────────
    final newMembacaC = team.activePhase == GamePhase.membaca
        ? team.membacaCorrect + 1 : team.membacaCorrect;
    final newMenulisC = team.activePhase == GamePhase.menulis
        ? team.menulisCorrect + 1 : team.menulisCorrect;
    final newBerhitungC = team.activePhase == GamePhase.berhitung
        ? team.berhitungCorrect + 1 : team.berhitungCorrect;

    // ── Cek apakah fase ini selesai (5 soal) ─────────────────
    final newQIndex = team.questionIndex + 1;
    final isPhaseComplete = newQIndex >= kQuestionsPerPhase;

    TeamState newTeam;

    if (isPhaseComplete) {
      // Bonus menyelesaikan fase lebih cepat dari timer
      final phaseBonus = (team.timeLeft / kTimerSeconds * 15).round();
      final nextPhase = _nextPhase(team.activePhase);

      final feedback = phaseBonus > 0
          ? '✅ Fase Selesai! ⚡ +$phaseBonus bonus!'
          : '✅ Fase Selesai!';

      newTeam = TeamState(
        id: team.id,
        totalScore: team.totalScore + scoreGain + phaseBonus,
        activePhase: nextPhase,
        questionIndex: 0,
        timeLeft: nextPhase == GamePhase.finished ? 0 : kTimerSeconds,
        membacaCorrect: newMembacaC,
        menulisCorrect: newMenulisC,
        berhitungCorrect: newBerhitungC,
        lastFeedback: feedback,
        lastIsCorrect: true,
      );
    } else {
      final feedback = timeBonus > 0
          ? '🎉 Benar! ⚡ +$timeBonus'
          : '🎉 Benar!';

      newTeam = team.copyWith(
        totalScore: team.totalScore + scoreGain,
        questionIndex: newQIndex,
        membacaCorrect: newMembacaC,
        menulisCorrect: newMenulisC,
        berhitungCorrect: newBerhitungC,
        lastFeedback: feedback,
        lastIsCorrect: true,
      );
    }

    final newBlue = isBlue ? newTeam : state.blueTeam;
    final newRed = isBlue ? state.redTeam : newTeam;

    // ── Cek apakah global phase harus maju ───────────────────
    GamePhase newGlobalPhase = state.phase;
    if (newBlue.activePhase == GamePhase.finished && newRed.activePhase == GamePhase.finished) {
      newGlobalPhase = GamePhase.finished;
    }

    state = state.copyWith(
      phase: newGlobalPhase,
      blueTeam: newBlue,
      redTeam: newRed,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────
  GamePhase _nextPhase(GamePhase p) {
    switch (p) {
      case GamePhase.countdown: return GamePhase.membaca;
      case GamePhase.membaca: return GamePhase.menulis;
      case GamePhase.menulis: return GamePhase.berhitung;
      case GamePhase.berhitung: return GamePhase.finished;
      case GamePhase.finished: return GamePhase.finished;
    }
  }

  // ─── Restart ─────────────────────────────────────────────────
  void restart() {
    state = CompetitiveState(
      blueTeam: const TeamState(id: TeamId.blue, timeLeft: kTimerSeconds),
      redTeam: const TeamState(id: TeamId.red, timeLeft: kTimerSeconds),
      membacaQ: CompetitiveQuestions.membacaList..shuffle(),
      menulisQ: CompetitiveQuestions.menulisList..shuffle(),
      berhitungQ: CompetitiveQuestions.berhitungList..shuffle(),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────
final competitiveProvider =
    StateNotifierProvider<CompetitiveNotifier, CompetitiveState>((ref) {
  return CompetitiveNotifier();
});
