import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/membaca_data.dart';

// ─── State ────────────────────────────────────────────────────
enum MembacaMode { huruf, kata, kalimat }

class MembacaState {
  final MembacaMode mode;
  final int currentIndex;
  final bool showAnswer;
  final int score;
  final List<String> shuffledSukuKata;
  final List<String> arrangedSukuKata;
  final bool isCorrect;
  final bool isError;

  const MembacaState({
    this.mode = MembacaMode.huruf,
    this.currentIndex = 0,
    this.showAnswer = false,
    this.score = 0,
    this.shuffledSukuKata = const [],
    this.arrangedSukuKata = const [],
    this.isCorrect = false,
    this.isError = false,
  });

  MembacaState copyWith({
    MembacaMode? mode,
    int? currentIndex,
    bool? showAnswer,
    int? score,
    List<String>? shuffledSukuKata,
    List<String>? arrangedSukuKata,
    bool? isCorrect,
    bool? isError,
  }) {
    return MembacaState(
      mode: mode ?? this.mode,
      currentIndex: currentIndex ?? this.currentIndex,
      showAnswer: showAnswer ?? this.showAnswer,
      score: score ?? this.score,
      shuffledSukuKata: shuffledSukuKata ?? this.shuffledSukuKata,
      arrangedSukuKata: arrangedSukuKata ?? this.arrangedSukuKata,
      isCorrect: isCorrect ?? this.isCorrect,
      isError: isError ?? this.isError,
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

  void _initKalimatMode() {
    final kalimat = MembacaData.kalimatLatihan[state.currentIndex];
    final shuffled = List<String>.from(kalimat.potonganKata)..shuffle();
    state = state.copyWith(
      shuffledSukuKata: shuffled,
      arrangedSukuKata: [],
      isCorrect: false,
    );
  }

  void setMode(MembacaMode mode) {
    state = state.copyWith(mode: mode, currentIndex: 0, score: 0);
    if (mode == MembacaMode.kata) _initKataMode();
    if (mode == MembacaMode.kalimat) _initKalimatMode();
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
  Future<void> pickSukuKata(String suku) async {
    List<String> sourceList;
    String targetAnswer;

    if (state.mode == MembacaMode.kalimat) {
      final k = MembacaData.kalimatLatihan[state.currentIndex];
      sourceList = k.potonganKata;
      targetAnswer = k.kalimatUtuh;
    } else {
      final k = MembacaData.kataLatihan[state.currentIndex];
      sourceList = k.sukuKata;
      targetAnswer = k.kata;
    }

    final totalInSource = sourceList.where((s) => s == suku).length;
    final usedCount = state.arrangedSukuKata.where((s) => s == suku).length;
    // Jika sudah semua terpakai, tolak
    if (usedCount >= totalInSource) return;

    final arranged = [...state.arrangedSukuKata, suku];
    bool correct = false;
    bool error = false;
    
    if (arranged.length == sourceList.length) {
      if (state.mode == MembacaMode.kalimat) {
        correct = arranged.join(' ') == targetAnswer;
      } else {
        correct = arranged.join('') == targetAnswer;
      }
      if (!correct) {
        error = true;
      }
    }

    state = state.copyWith(
      arrangedSukuKata: arranged,
      isCorrect: correct,
      isError: error,
      score: correct ? state.score + 10 : state.score,
    );

    if (error) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted && state.isError) {
        state = state.copyWith(arrangedSukuKata: [], isError: false);
      }
    }
  }

  void submitAnswer(bool isCorrect) async {
    if (isCorrect) {
      state = state.copyWith(isCorrect: true, score: state.score + 10);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted && state.isCorrect) {
        state = state.copyWith(isCorrect: false);
        nextKata();
      }
    } else {
      state = state.copyWith(isError: true);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted && state.isError) {
        state = state.copyWith(isError: false);
      }
    }
  }

  void removeSukuKata(String suku) {
    // Hapus hanya SATU kemunculan terakhir dari suku ini
    final arranged = List<String>.from(state.arrangedSukuKata);
    final lastIdx = arranged.lastIndexOf(suku);
    if (lastIdx != -1) arranged.removeAt(lastIdx);
    state = state.copyWith(arrangedSukuKata: arranged, isCorrect: false);
  }

  void nextKata() {
    if (state.mode == MembacaMode.kalimat) {
      final next = (state.currentIndex + 1) % MembacaData.kalimatLatihan.length;
      state = state.copyWith(currentIndex: next);
      _initKalimatMode();
    } else {
      final next = (state.currentIndex + 1) % MembacaData.kataLatihan.length;
      state = state.copyWith(currentIndex: next);
      _initKataMode();
    }
  }

  void reset() {
    state = const MembacaState();
    if (state.mode == MembacaMode.kalimat) {
      _initKalimatMode();
    } else {
      _initKataMode();
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────
final membacaProvider =
    StateNotifierProvider<MembacaNotifier, MembacaState>((ref) {
  return MembacaNotifier();
});
