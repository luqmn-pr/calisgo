import 'dart:math';
import 'dart:typed_data';

/// Jenis suara yang tersedia dalam game
enum SoundType {
  correct,      // Jawaban benar  — nada naik C5-E5-G5
  incorrect,    // Jawaban salah  — nada turun G4-E4
  tap,          // Ketuk tombol   — click pendek
  pop,          // Pilih item     — pop lembut
  celebration,  // Level selesai  — fanfare C5-E5-G5-C6
  countdown,    // Hitung mundur  — tick
  countdownGo,  // Mulai!         — ascending beep
  whoosh,       // Navigasi       — frequency sweep
  bgm,          // Background music — music box melody
}

/// Generator suara WAV secara programatik.
///
/// Menggunakan sintesis gelombang sinus dengan harmonik untuk
/// menghasilkan suara yang lebih kaya. Semua suara di-cache
/// setelah pertama kali di-generate.
class SoundGenerator {
  SoundGenerator._();

  static const int _sampleRate = 44100;
  static final Map<SoundType, Uint8List> _cache = {};

  /// Mendapatkan data WAV untuk [type] tertentu (cached).
  static Uint8List getSound(SoundType type) {
    return _cache.putIfAbsent(type, () => _generate(type));
  }

  static Uint8List _generate(SoundType type) {
    switch (type) {
      case SoundType.correct:
        return _toneSequence([
          (523.25, 0.12, 0.5), // C5
          (659.25, 0.12, 0.5), // E5
          (783.99, 0.20, 0.6), // G5
        ]);
      case SoundType.incorrect:
        return _toneSequence([
          (392.00, 0.15, 0.4), // G4
          (329.63, 0.22, 0.35), // E4
        ]);
      case SoundType.tap:
        return _toneSequence([(880.0, 0.06, 0.3)]);
      case SoundType.pop:
        return _toneSequence([(660.0, 0.08, 0.35)]);
      case SoundType.celebration:
        return _toneSequence([
          (523.25, 0.15, 0.5), // C5
          (659.25, 0.15, 0.5), // E5
          (783.99, 0.15, 0.5), // G5
          (1046.50, 0.35, 0.6), // C6
        ]);
      case SoundType.countdown:
        return _toneSequence([(440.0, 0.12, 0.4)]);
      case SoundType.countdownGo:
        return _toneSequence([
          (440.0, 0.10, 0.4),
          (880.0, 0.25, 0.5),
        ]);
      case SoundType.whoosh:
        return _sweep(1200, 300, 0.15, 0.25);
      case SoundType.bgm:
        return _musicBox();
    }
  }

  // ── Sequence of tones ────────────────────────────────────────
  // Each tuple: (frequency Hz, duration seconds, amplitude 0-1)
  static Uint8List _toneSequence(List<(double, double, double)> notes) {
    int totalSamples = 0;
    for (final (_, dur, _) in notes) {
      totalSamples += (dur * _sampleRate).round();
    }

    final pcm = Float64List(totalSamples);
    int offset = 0;

    for (final (freq, dur, amp) in notes) {
      final n = (dur * _sampleRate).round();
      for (int i = 0; i < n; i++) {
        final t = i / n;

        // ADSR envelope
        double env;
        if (t < 0.05) {
          env = t / 0.05; // attack
        } else if (t < 0.3) {
          env = 1.0; // sustain
        } else {
          env = 1.0 - ((t - 0.3) / 0.7); // release
        }
        env = env.clamp(0.0, 1.0);

        // Sine wave + harmonics for richer timbre
        final sample = amp *
            env *
            (sin(2 * pi * freq * i / _sampleRate) * 0.7 +
                sin(2 * pi * freq * 2 * i / _sampleRate) * 0.2 +
                sin(2 * pi * freq * 3 * i / _sampleRate) * 0.1);
        pcm[offset + i] = sample;
      }
      offset += n;
    }

    return _encodeWav(pcm);
  }

  // ── Frequency sweep (whoosh) ─────────────────────────────────
  static Uint8List _sweep(
      double startHz, double endHz, double duration, double amplitude) {
    final n = (duration * _sampleRate).round();
    final pcm = Float64List(n);

    for (int i = 0; i < n; i++) {
      final t = i / n;
      final freq = startHz + (endHz - startHz) * t;
      final env = (1.0 - t) * amplitude;
      pcm[i] = env * sin(2 * pi * freq * i / _sampleRate);
    }

    return _encodeWav(pcm);
  }

  // ── Music Box BGM ────────────────────────────────────────────
  // Pentatonic melody: C D E G A — cheerful & child-friendly
  static Uint8List _musicBox() {
    const c4 = 261.63, d4 = 293.66, e4 = 329.63;
    const g4 = 392.00, a4 = 440.00;
    const c5 = 523.25;

    // melody: (frequency, duration in seconds)
    final melody = <(double, double)>[
      // Phrase 1 — naik
      (c4, 0.28), (e4, 0.28), (g4, 0.28), (c5, 0.55),
      // Phrase 2 — turun
      (a4, 0.28), (g4, 0.28), (e4, 0.28), (d4, 0.55),
      // Phrase 3 — naik lagi
      (e4, 0.28), (g4, 0.28), (a4, 0.28), (c5, 0.55),
      // Phrase 4 — turun ke root
      (g4, 0.28), (e4, 0.28), (d4, 0.28), (c4, 0.55),
      // Phrase 5 — variasi
      (c4, 0.20), (d4, 0.20), (e4, 0.28), (g4, 0.28),
      (a4, 0.28), (c5, 0.65),
      // Phrase 6 — resolusi
      (a4, 0.20), (g4, 0.20), (e4, 0.28), (d4, 0.28),
      (c4, 0.28), (c4, 0.65),
    ];

    // Calculate total samples
    int totalSamples = 0;
    for (final (_, dur) in melody) {
      totalSamples += (dur * _sampleRate).round();
    }

    final pcm = Float64List(totalSamples);
    int offset = 0;
    const amplitude = 0.35;

    for (final (freq, dur) in melody) {
      final n = (dur * _sampleRate).round();
      for (int i = 0; i < n; i++) {
        final t = i / n;
        // Music box envelope: quick attack, exponential decay
        final env = exp(-3.0 * t);

        // Music box timbre: fundamental + octave + 3rd harmonic
        final sample = amplitude *
            env *
            (sin(2 * pi * freq * i / _sampleRate) * 0.6 +
                sin(2 * pi * freq * 2 * i / _sampleRate) * 0.3 +
                sin(2 * pi * freq * 3 * i / _sampleRate) * 0.1);
        pcm[offset + i] = sample;
      }
      offset += n;
    }

    return _encodeWav(pcm);
  }

  // ── WAV encoder ──────────────────────────────────────────────
  // PCM 16-bit mono, 44100 Hz
  static Uint8List _encodeWav(Float64List samples) {
    final dataSize = samples.length * 2;
    final fileSize = 44 + dataSize;
    final buffer = ByteData(fileSize);

    // RIFF header
    _writeAscii(buffer, 0, 'RIFF');
    buffer.setUint32(4, fileSize - 8, Endian.little);
    _writeAscii(buffer, 8, 'WAVE');

    // fmt sub-chunk
    _writeAscii(buffer, 12, 'fmt ');
    buffer.setUint32(16, 16, Endian.little); // sub-chunk size
    buffer.setUint16(20, 1, Endian.little); // PCM format
    buffer.setUint16(22, 1, Endian.little); // mono
    buffer.setUint32(24, _sampleRate, Endian.little);
    buffer.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
    buffer.setUint16(32, 2, Endian.little); // block align
    buffer.setUint16(34, 16, Endian.little); // bits per sample

    // data sub-chunk
    _writeAscii(buffer, 36, 'data');
    buffer.setUint32(40, dataSize, Endian.little);

    for (int i = 0; i < samples.length; i++) {
      final s = (samples[i] * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(44 + i * 2, s, Endian.little);
    }

    return buffer.buffer.asUint8List();
  }

  static void _writeAscii(ByteData data, int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
}
