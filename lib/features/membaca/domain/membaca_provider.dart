import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/membaca_data.dart';

// ─── State ────────────────────────────────────────────────────
enum MembacaMode { huruf, kata }

class MembacaState {
  final MembacaMode mode;
  final int currentIndex;
  final bool showAnswer;
  final int score;
  final List<String> shuffledSukuKata;
  final List<String> arrangedSukuKata;
  final bool isCorrect;

  const MembacaState({
    this.mode = MembacaMode.huruf,
    this.currentIndex = 0,
    this.showAnswer = false,
    this.score = 0,
    this.shuffledSukuKata = const [],
    this.arrangedSukuKata = const [],
    this.isCorrect = false,
  });

  MembacaState copyWith({
    MembacaMode? mode,
    int? currentIndex,
    bool? showAnswer,
    int? score,
    List<String>? shuffledSukuKata,
    List<String>? arrangedSukuKata,
    bool? isCorrect,
  }) {
    return MembacaState(
      mode: mode ?? this.mode,
      currentIndex: currentIndex ?? this.currentIndex,
      showAnswer: showAnswer ?? this.showAnswer,
      score: score ?? this.score,
      shuffledSukuKata: shuffledSukuKata ?? this.shuffledSukuKata,
      arrangedSukuKata: arrangedSukuKata ?? this.arrangedSukuKata,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────
class MembacaNotifier extends StateNotifier<MembacaState> {
  MembacaNotifier() : super(const MembacaState()) {
    _initKataMode();
  }

  void _initKataMode() {
    final kata = MembacaData.kataLatihan[state.currentIndex];
    final shuffled = List<String>.from(kata.sukuKata)..shuffle();
    state = state.copyWith(
      shuffledSukuKata: shuffled,
      arrangedSukuKata: [],
      isCorrect: false,
    );
  }

  void setMode(MembacaMode mode) {
    state = state.copyWith(mode: mode, currentIndex: 0, score: 0);
    if (mode == MembacaMode.kata) _initKataMode();
  }

  void nextHuruf() {
    final next = (state.currentIndex + 1) % MembacaData.hurufAZ.length;
    state = state.copyWith(currentIndex: next, showAnswer: false);
  }

  void prevHuruf() {
    final prev = (state.currentIndex - 1 + MembacaData.hurufAZ.length) %
        MembacaData.hurufAZ.length;
    state = state.copyWith(currentIndex: prev, showAnswer: false);
  }

  void toggleAnswer() {
    state = state.copyWith(showAnswer: !state.showAnswer);
  }

  // Suku kata drag-and-drop logic
  void pickSukuKata(String suku) {
    if (state.arrangedSukuKata.contains(suku)) return;
    final arranged = [...state.arrangedSukuKata, suku];
    final kata = MembacaData.kataLatihan[state.currentIndex];

    bool correct = false;
    if (arranged.length == kata.sukuKata.length) {
      correct = arranged.join('') == kata.kata;
    }

    state = state.copyWith(
      arrangedSukuKata: arranged,
      isCorrect: correct,
      score: correct ? state.score + 10 : state.score,
    );
  }

  void removeSukuKata(String suku) {
    final arranged = List<String>.from(state.arrangedSukuKata)..remove(suku);
    state = state.copyWith(arrangedSukuKata: arranged, isCorrect: false);
  }

  void nextKata() {
    final next = (state.currentIndex + 1) % MembacaData.kataLatihan.length;
    state = state.copyWith(currentIndex: next);
    _initKataMode();
  }

  void reset() {
    state = const MembacaState();
    _initKataMode();
  }
}

// ─── Provider ─────────────────────────────────────────────────
final membacaProvider =
    StateNotifierProvider<MembacaNotifier, MembacaState>((ref) {
  return MembacaNotifier();
});
