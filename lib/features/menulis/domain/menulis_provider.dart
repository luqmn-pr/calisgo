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
  static const double kProximityThreshold = 0.12; // 12% of canvas size (lebih toleran)
  static const double kMinAccuracy = 0.50; // Minimum 50% match for children

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
    final targetCheckpoints =
        state.currentLetter.checkpoints[state.currentStrokeIndex];
    
    final accuracy = _computeAccuracy(state.currentPath, targetCheckpoints, targetStroke);

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
  double _computeAccuracy(
      List<Offset> userPath, List<Offset> targetCheckpoints, List<Offset> fullTargetStroke) {
    if (userPath.isEmpty || targetCheckpoints.isEmpty) return 0.0;

    int userIndex = 0;

    // 1. Cek Checkpoints (Wajib mengenai SEMUA titik utama secara berurutan)
    // Ini akan menggagalkan coretan yang berhenti di tengah jalan (seperti gambar 1, 2, 4)
    for (final targetPt in targetCheckpoints) {
      bool matched = false;
      for (int i = userIndex; i < userPath.length; i++) {
        final d = _distance(targetPt, userPath[i]);
        if (d <= kProximityThreshold) {
          matched = true;
          userIndex = i; // Simpan index agar berurutan
          break;
        }
      }
      if (!matched) return 0.0; // Jika ada 1 titik saja yang terlewat, langsung gagal
    }

    // 2. Anti-Hook / Anti-Trailing Scribble (Wajib berhenti di dekat titik akhir)
    // Ini akan menggagalkan coretan tambahan di akhir (seperti gambar 3)
    final lastTargetPt = fullTargetStroke.last;
    final lastUserPt = userPath.last;
    if (_distance(lastUserPt, lastTargetPt) > kProximityThreshold * 1.5) {
      return 0.0; // Titik akhir coretan terlalu jauh dari ujung huruf asli
    }

    // 3. Anti-Wandering (Jarak titik pengguna ke SEGMENT GARIS target tidak boleh jauh)
    for (final userPt in userPath) {
      double minD = double.infinity;
      // Hitung jarak terdekat dari userPt ke semua segmen garis di fullTargetStroke
      for (int i = 0; i < fullTargetStroke.length - 1; i++) {
        final d = _distanceToSegment(userPt, fullTargetStroke[i], fullTargetStroke[i+1]);
        if (d < minD) minD = d;
      }
      // Batas toleransi diperketat menjadi 1.2x (sekitar 14% layar)
      if (minD > kProximityThreshold * 1.2) {
        return 0.0; 
      }
    }

    // 4. Anti-Scribble (Cek panjang total coretan)
    double targetLen = _pathLength(fullTargetStroke);
    double userLen = _pathLength(userPath);
    
    // Coretan tidak boleh melampaui 1.8x panjang garis aslinya
    if (targetLen > 0 && userLen > targetLen * 1.8) {
      return 0.0; 
    }

    // Jika lolos semua validasi ketat ini, berarti coretan sangat akurat!
    return 1.0;
  }

  // Jarak terpendek dari titik p ke segmen garis v-w
  double _distanceToSegment(Offset p, Offset v, Offset w) {
    final l2 = pow(v.dx - w.dx, 2) + pow(v.dy - w.dy, 2);
    if (l2 == 0) return _distance(p, v);
    double t = ((p.dx - v.dx) * (w.dx - v.dx) + (p.dy - v.dy) * (w.dy - v.dy)) / l2;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(v.dx + t * (w.dx - v.dx), v.dy + t * (w.dy - v.dy));
    return _distance(p, projection);
  }

  double _pathLength(List<Offset> path) {
    double len = 0;
    for (int i = 1; i < path.length; i++) {
      len += _distance(path[i-1], path[i]);
    }
    return len;
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
