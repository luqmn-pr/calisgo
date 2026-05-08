import 'dart:math';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/menulis_data.dart';

// ─── Enum ─────────────────────────────────────────────────────
enum TracingPhase { idle, tracing, complete, error }

// ─── State ────────────────────────────────────────────────────
class MenulisState {
  final int currentLetterIndex;
  final int currentStrokeIndex;
  final List<Offset> currentPath;
  final List<List<Offset>> completedStrokes;
  final TracingPhase phase;
  final double accuracy;
  final int score;
  final String feedbackMessage;
  final List<LetterStroke> items;

  const MenulisState({
    this.currentLetterIndex = 0,
    this.currentStrokeIndex = 0,
    this.currentPath = const [],
    this.completedStrokes = const [],
    this.phase = TracingPhase.idle,
    this.accuracy = 0.0,
    this.score = 0,
    this.feedbackMessage = '',
    this.items = const [],
  });

  MenulisState copyWith({
    int? currentLetterIndex,
    int? currentStrokeIndex,
    List<Offset>? currentPath,
    List<List<Offset>>? completedStrokes,
    TracingPhase? phase,
    double? accuracy,
    int? score,
    String? feedbackMessage,
    List<LetterStroke>? items,
  }) =>
      MenulisState(
        currentLetterIndex: currentLetterIndex ?? this.currentLetterIndex,
        currentStrokeIndex: currentStrokeIndex ?? this.currentStrokeIndex,
        currentPath: currentPath ?? this.currentPath,
        completedStrokes: completedStrokes ?? this.completedStrokes,
        phase: phase ?? this.phase,
        accuracy: accuracy ?? this.accuracy,
        score: score ?? this.score,
        feedbackMessage: feedbackMessage ?? this.feedbackMessage,
        items: items ?? this.items,
      );

  LetterStroke get currentLetter => items[currentLetterIndex];
  bool get isLastStroke =>
      currentStrokeIndex >= currentLetter.strokes.length - 1;
}

// ─── Notifier ─────────────────────────────────────────────────
class MenulisNotifier extends StateNotifier<MenulisState> {
  static const double kProximityThreshold = 0.06; // 6% of canvas size
  static const double kMinAccuracy = 0.60; // Minimum 60% match for children

  MenulisNotifier()
      : super(MenulisState(items: MenulisData.allItems));

  void startStroke(Offset normalized) {
    state = state.copyWith(
      phase: TracingPhase.tracing,
      currentPath: [normalized],
    );
  }

  void updateStroke(Offset normalized) {
    if (state.phase != TracingPhase.tracing) return;
    state = state.copyWith(
      currentPath: [...state.currentPath, normalized],
    );
  }

  void endStroke(Size canvasSize) {
    if (state.phase != TracingPhase.tracing) return;

    final targetStroke =
        state.currentLetter.strokes[state.currentStrokeIndex];
    final accuracy = _computeAccuracy(state.currentPath, targetStroke);

    if (accuracy >= kMinAccuracy) {
      final completed = [...state.completedStrokes, state.currentPath];

      if (state.isLastStroke) {
        // All strokes done!
        state = state.copyWith(
          completedStrokes: completed,
          currentPath: [],
          phase: TracingPhase.complete,
          accuracy: accuracy,
          score: state.score + (accuracy * 10).round(),
          feedbackMessage: _getPositiveFeedback(),
        );
      } else {
        // Next stroke
        state = state.copyWith(
          completedStrokes: completed,
          currentPath: [],
          currentStrokeIndex: state.currentStrokeIndex + 1,
          phase: TracingPhase.idle,
          accuracy: accuracy,
          feedbackMessage: 'Bagus! Lanjutkan stroke berikutnya ✓',
        );
      }
    } else {
      state = state.copyWith(
        currentPath: [],
        phase: TracingPhase.error,
        feedbackMessage: 'Coba lagi ya! Ikuti garis putus-putus 😊',
      );
    }
  }

  void clearStroke() {
    state = state.copyWith(
      currentPath: [],
      phase: TracingPhase.idle,
      feedbackMessage: '',
    );
  }

  void nextLetter() {
    final next = (state.currentLetterIndex + 1) % state.items.length;
    state = MenulisState(
      items: state.items,
      currentLetterIndex: next,
      score: state.score,
    );
  }

  void prevLetter() {
    final prev =
        (state.currentLetterIndex - 1 + state.items.length) %
            state.items.length;
    state = MenulisState(
      items: state.items,
      currentLetterIndex: prev,
      score: state.score,
    );
  }

  void reset() {
    state = MenulisState(items: state.items, score: state.score);
  }

  // ─── Algoritma Akurasi ──────────────────────────────────
  // Menghitung proximity match antara user path dan target path
  // Menggunakan sampling + minimum distance per target point
  double _computeAccuracy(
      List<Offset> userPath, List<Offset> targetPath) {
    if (userPath.isEmpty || targetPath.isEmpty) return 0.0;

    int matchedPoints = 0;
    for (final targetPt in targetPath) {
      double minDist = double.infinity;
      for (final userPt in userPath) {
        final d = _distance(targetPt, userPt);
        if (d < minDist) minDist = d;
      }
      if (minDist <= kProximityThreshold) matchedPoints++;
    }

    return matchedPoints / targetPath.length;
  }

  double _distance(Offset a, Offset b) {
    return sqrt(pow(a.dx - b.dx, 2) + pow(a.dy - b.dy, 2));
  }

  String _getPositiveFeedback() {
    const messages = [
      '🌟 Wah, kamu hebat!',
      '🎉 Bagus sekali!',
      '⭐ Luar biasa!',
      '🏆 Mantap!',
      '🎊 Kamu bisa!',
    ];
    return messages[DateTime.now().second % messages.length];
  }
}

// ─── Provider ─────────────────────────────────────────────────
final menulisProvider =
    StateNotifierProvider<MenulisNotifier, MenulisState>((ref) {
  return MenulisNotifier();
});
