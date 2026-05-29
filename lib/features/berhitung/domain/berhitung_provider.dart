import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/berhitung_data.dart';

// ─── State ────────────────────────────────────────────────────
enum BerhitungPhase { answering, correct, incorrect, finished }

class BerhitungState {
  final List<BerhitungSoal> soalList;
  final int currentIndex;
  final int? selectedAnswer;
  final BerhitungPhase phase;
  final int score;
  final int correctCount;

  const BerhitungState({
    this.soalList = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.phase = BerhitungPhase.answering,
    this.score = 0,
    this.correctCount = 0,
  });

  BerhitungState copyWith({
    List<BerhitungSoal>? soalList,
    int? currentIndex,
    int? selectedAnswer,
    BerhitungPhase? phase,
    int? score,
    int? correctCount,
  }) =>
      BerhitungState(
        soalList: soalList ?? this.soalList,
        currentIndex: currentIndex ?? this.currentIndex,
        selectedAnswer: selectedAnswer ?? this.selectedAnswer,
        phase: phase ?? this.phase,
        score: score ?? this.score,
        correctCount: correctCount ?? this.correctCount,
      );

  BerhitungSoal get currentSoal => soalList[currentIndex];
  // isFinished: currentIndex sudah melewati batas list
  bool get isFinished => soalList.isEmpty || currentIndex >= soalList.length;
  double get progress =>
      soalList.isEmpty ? 0 : (currentIndex / soalList.length).clamp(0.0, 1.0);

  /// answerChoices hanya valid jika !isFinished
  List<int> get answerChoices {
    if (isFinished) return [];
    final correct = currentSoal.jawaban;
    final Set<int> choices = {correct};
    int attempt = 0;
    while (choices.length < 4 && attempt < 20) {
      final offset = (attempt % 5) + 1;
      final candidate = correct + (attempt.isEven ? offset : -offset);
      if (candidate >= 0 && candidate <= 10) choices.add(candidate);
      attempt++;
    }
    return choices.toList()..shuffle();
  }
}

// ─── Notifier ─────────────────────────────────────────────────
class BerhitungNotifier extends StateNotifier<BerhitungState> {
  BerhitungNotifier()
      : super(BerhitungState(soalList: BerhitungData.generateSoalList()));

  void selectAnswer(int answer) {
    if (state.phase != BerhitungPhase.answering) return;

    final isCorrect = answer == state.currentSoal.jawaban;
    state = state.copyWith(
      selectedAnswer: answer,
      phase: isCorrect ? BerhitungPhase.correct : BerhitungPhase.incorrect,
      score: isCorrect ? state.score + 10 : state.score,
      correctCount:
          isCorrect ? state.correctCount + 1 : state.correctCount,
    );
  }

  void nextSoal() {
    final nextIndex = state.currentIndex + 1;
    if (nextIndex >= state.soalList.length) {
      state = state.copyWith(
        currentIndex: nextIndex,
        phase: BerhitungPhase.finished,
      );
    } else {
      state = state.copyWith(
        currentIndex: nextIndex,
        selectedAnswer: null,
        phase: BerhitungPhase.answering,
      );
    }
  }

  void restart() {
    state = BerhitungState(soalList: BerhitungData.generateSoalList());
  }
}

// ─── Provider ─────────────────────────────────────────────────
final berhitungProvider =
    StateNotifierProvider<BerhitungNotifier, BerhitungState>((ref) {
  return BerhitungNotifier();
});
