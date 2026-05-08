import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Team Model ───────────────────────────────────────────────
enum TeamId { blue, red }

class TeamState {
  final TeamId id;
  final int score;
  final int correctCount;
  final int incorrectCount;
  final String lastFeedback;
  final bool isCorrect;

  const TeamState({
    required this.id,
    this.score = 0,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.lastFeedback = '',
    this.isCorrect = false,
  });

  TeamState copyWith({
    int? score,
    int? correctCount,
    int? incorrectCount,
    String? lastFeedback,
    bool? isCorrect,
  }) =>
      TeamState(
        id: id,
        score: score ?? this.score,
        correctCount: correctCount ?? this.correctCount,
        incorrectCount: incorrectCount ?? this.incorrectCount,
        lastFeedback: lastFeedback ?? this.lastFeedback,
        isCorrect: isCorrect ?? this.isCorrect,
      );
}

// ─── Soal Kompetisi ───────────────────────────────────────────
class CompetitiveSoal {
  final String question;
  final int answer;
  final List<int> choices;
  final String emoji;

  const CompetitiveSoal({
    required this.question,
    required this.answer,
    required this.choices,
    required this.emoji,
  });
}

List<CompetitiveSoal> _generateSoal() {
  return [
    CompetitiveSoal(
      question: '2 + 3 = ?', answer: 5,
      choices: [3, 4, 5, 6], emoji: '⭐',
    ),
    CompetitiveSoal(
      question: '4 - 1 = ?', answer: 3,
      choices: [2, 3, 4, 5], emoji: '🍎',
    ),
    CompetitiveSoal(
      question: '1 + 1 = ?', answer: 2,
      choices: [1, 2, 3, 4], emoji: '🎈',
    ),
    CompetitiveSoal(
      question: '5 - 3 = ?', answer: 2,
      choices: [1, 2, 3, 4], emoji: '🌸',
    ),
    CompetitiveSoal(
      question: '3 + 2 = ?', answer: 5,
      choices: [4, 5, 6, 7], emoji: '🍭',
    ),
    CompetitiveSoal(
      question: '4 + 1 = ?', answer: 5,
      choices: [3, 4, 5, 6], emoji: '🚀',
    ),
    CompetitiveSoal(
      question: '6 - 2 = ?', answer: 4,
      choices: [3, 4, 5, 6], emoji: '🎵',
    ),
    CompetitiveSoal(
      question: '2 + 2 = ?', answer: 4,
      choices: [2, 3, 4, 5], emoji: '🌈',
    ),
    CompetitiveSoal(
      question: '5 - 1 = ?', answer: 4,
      choices: [3, 4, 5, 6], emoji: '🏆',
    ),
    CompetitiveSoal(
      question: '3 + 3 = ?', answer: 6,
      choices: [4, 5, 6, 7], emoji: '⚡',
    ),
  ];
}

// ─── Competitive State ────────────────────────────────────────
enum GamePhase { countdown, playing, finished }

class CompetitiveState {
  final TeamState blueTeam;
  final TeamState redTeam;
  final List<CompetitiveSoal> soalList;
  final int blueIndex;
  final int redIndex;
  final GamePhase phase;
  final int timeLeft; // seconds
  final int countdownValue;

  const CompetitiveState({
    required this.blueTeam,
    required this.redTeam,
    this.soalList = const [],
    this.blueIndex = 0,
    this.redIndex = 0,
    this.phase = GamePhase.countdown,
    this.timeLeft = 60,
    this.countdownValue = 3,
  });

  CompetitiveSoal get blueSoal => soalList[blueIndex % soalList.length];
  CompetitiveSoal get redSoal => soalList[redIndex % soalList.length];

  CompetitiveState copyWith({
    TeamState? blueTeam,
    TeamState? redTeam,
    int? blueIndex,
    int? redIndex,
    GamePhase? phase,
    int? timeLeft,
    int? countdownValue,
  }) =>
      CompetitiveState(
        blueTeam: blueTeam ?? this.blueTeam,
        redTeam: redTeam ?? this.redTeam,
        soalList: soalList,
        blueIndex: blueIndex ?? this.blueIndex,
        redIndex: redIndex ?? this.redIndex,
        phase: phase ?? this.phase,
        timeLeft: timeLeft ?? this.timeLeft,
        countdownValue: countdownValue ?? this.countdownValue,
      );

  TeamId? get winner {
    if (phase != GamePhase.finished) return null;
    if (blueTeam.score > redTeam.score) return TeamId.blue;
    if (redTeam.score > blueTeam.score) return TeamId.red;
    return null; // draw
  }
}

// ─── Notifier ─────────────────────────────────────────────────
class CompetitiveNotifier extends StateNotifier<CompetitiveState> {
  CompetitiveNotifier()
      : super(CompetitiveState(
          blueTeam: const TeamState(id: TeamId.blue),
          redTeam: const TeamState(id: TeamId.red),
          soalList: _generateSoal(),
        ));

  void answerBlue(int answer) {
    if (state.phase != GamePhase.playing) return;
    final correct = answer == state.blueSoal.answer;
    state = state.copyWith(
      blueTeam: state.blueTeam.copyWith(
        score: correct ? state.blueTeam.score + 10 : state.blueTeam.score,
        correctCount: correct
            ? state.blueTeam.correctCount + 1
            : state.blueTeam.correctCount,
        incorrectCount: correct
            ? state.blueTeam.incorrectCount
            : state.blueTeam.incorrectCount + 1,
        lastFeedback: correct ? '🎉 Benar!' : '😅 Salah!',
        isCorrect: correct,
      ),
      blueIndex: state.blueIndex + 1,
    );
  }

  void answerRed(int answer) {
    if (state.phase != GamePhase.playing) return;
    final correct = answer == state.redSoal.answer;
    state = state.copyWith(
      redTeam: state.redTeam.copyWith(
        score: correct ? state.redTeam.score + 10 : state.redTeam.score,
        correctCount: correct
            ? state.redTeam.correctCount + 1
            : state.redTeam.correctCount,
        incorrectCount: correct
            ? state.redTeam.incorrectCount
            : state.redTeam.incorrectCount + 1,
        lastFeedback: correct ? '🎉 Benar!' : '😅 Salah!',
        isCorrect: correct,
      ),
      redIndex: state.redIndex + 1,
    );
  }

  void startCountdown() {
    state = state.copyWith(phase: GamePhase.countdown, countdownValue: 3);
  }

  void tickCountdown() {
    if (state.countdownValue > 1) {
      state = state.copyWith(countdownValue: state.countdownValue - 1);
    } else {
      state = state.copyWith(phase: GamePhase.playing);
    }
  }

  void tickTimer() {
    if (state.timeLeft > 1) {
      state = state.copyWith(timeLeft: state.timeLeft - 1);
    } else {
      state = state.copyWith(timeLeft: 0, phase: GamePhase.finished);
    }
  }

  void restart() {
    state = CompetitiveState(
      blueTeam: const TeamState(id: TeamId.blue),
      redTeam: const TeamState(id: TeamId.red),
      soalList: _generateSoal()..shuffle(),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────
final competitiveProvider =
    StateNotifierProvider<CompetitiveNotifier, CompetitiveState>((ref) {
  return CompetitiveNotifier();
});
