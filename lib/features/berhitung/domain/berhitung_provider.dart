import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/berhitung_data.dart';

// ─── State ────────────────────────────────────────────────────
enum BerhitungPhase { answering, correct, incorrect, finished }

class BerhitungState {
  final List<BerhitungSoal> soalList;
  final int currentIndex;
  final int objectsInBox;
  final int objectsOutside;
  final BerhitungPhase phase;
  final int score;
  final int correctCount;

  const BerhitungState({
    this.soalList = const [],
    this.currentIndex = 0,
    this.objectsInBox = 0,
    this.objectsOutside = 0,
    this.phase = BerhitungPhase.answering,
    this.score = 0,
    this.correctCount = 0,
  });

  BerhitungState copyWith({
    List<BerhitungSoal>? soalList,
    int? currentIndex,
    int? objectsInBox,
    int? objectsOutside,
    BerhitungPhase? phase,
    int? score,
    int? correctCount,
  }) =>
      BerhitungState(
        soalList: soalList ?? this.soalList,
        currentIndex: currentIndex ?? this.currentIndex,
        objectsInBox: objectsInBox ?? this.objectsInBox,
        objectsOutside: objectsOutside ?? this.objectsOutside,
        phase: phase ?? this.phase,
        score: score ?? this.score,
        correctCount: correctCount ?? this.correctCount,
      );

  BerhitungSoal get currentSoal => soalList[currentIndex];
  // isFinished: currentIndex sudah melewati batas list
  bool get isFinished => soalList.isEmpty || currentIndex >= soalList.length;
  double get progress =>
      soalList.isEmpty ? 0 : (currentIndex / soalList.length).clamp(0.0, 1.0);
}

// ─── Notifier ─────────────────────────────────────────────────
class BerhitungNotifier extends StateNotifier<BerhitungState> {
  BerhitungNotifier()
      : super(BerhitungState(soalList: BerhitungData.generateSoalList())) {
    _initSoal();
  }

  void _initSoal() {
    if (state.isFinished) return;
    final soal = state.currentSoal;
    int inBox = 0;
    int outside = 0;
    
    switch (soal.type) {
      case SoalType.pengurangan:
        inBox = soal.angkaA;
        outside = 0;
        break;
      case SoalType.penjumlahan:
        inBox = soal.angkaA;
        outside = 10; // Jumlah tumpukan di luar
        break;
      case SoalType.menghitung:
        inBox = 0;
        outside = 10;
        break;
    }
    
    state = state.copyWith(
      objectsInBox: inBox,
      objectsOutside: outside,
      phase: BerhitungPhase.answering,
    );
  }

  void moveObjectToBox() {
    if (state.phase != BerhitungPhase.answering) return;
    if (state.objectsOutside > 0) {
      state = state.copyWith(
        objectsInBox: state.objectsInBox + 1,
        objectsOutside: state.objectsOutside - 1,
      );
    }
  }

  void moveObjectToOutside() {
    if (state.phase != BerhitungPhase.answering) return;
    if (state.objectsInBox > 0) {
      state = state.copyWith(
        objectsInBox: state.objectsInBox - 1,
        objectsOutside: state.objectsOutside + 1,
      );
    }
  }

  void checkAnswer() {
    if (state.phase != BerhitungPhase.answering) return;

    final isCorrect = state.objectsInBox == state.currentSoal.jawaban;
    state = state.copyWith(
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
      );
      _initSoal();
    }
  }

  void restart() {
    state = BerhitungState(soalList: BerhitungData.generateSoalList());
    _initSoal();
  }
}

// ─── Provider ─────────────────────────────────────────────────
final berhitungProvider =
    StateNotifierProvider<BerhitungNotifier, BerhitungState>((ref) {
  return BerhitungNotifier();
});
