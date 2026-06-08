import 'package:audioplayers/audioplayers.dart';
import 'sound_generator.dart';

/// Service untuk memanage semua audio playback dalam game.
///
/// Menggunakan satu [AudioPlayer] per tipe SFX (lazy-created)
/// dan satu [AudioPlayer] khusus untuk background music (loop).
class AudioService {
  final Map<SoundType, AudioPlayer> _sfxPlayers = {};
  AudioPlayer? _bgmPlayer;

  double _volume = 0.7;
  bool _isMuted = false;
  bool _sfxEnabled = true;
  bool _bgmEnabled = true;
  bool _bgmPlaying = false;

  AudioService() {
    _initAudioContext();
  }

  Future<void> _initAudioContext() async {
    try {
      await AudioPlayer.global.setAudioContext(AudioContextConfig(
        respectSilence: true,
        focus: AudioContextConfigFocus.mixWithOthers,
      ).build());
    } catch (_) {}
  }

  // ── SFX Playback ─────────────────────────────────────────────

  /// Mainkan efek suara [type]. Jika tipe = bgm, mulai background music.
  Future<void> playSound(SoundType type) async {
    if (_isMuted) return;

    if (type == SoundType.bgm) {
      await startBgm();
      return;
    }

    if (!_sfxEnabled) return;

    try {
      final player = _sfxPlayers.putIfAbsent(type, () => AudioPlayer());
      final bytes = SoundGenerator.getSound(type);
      await player.setVolume(_volume);
      await player.stop();
      await player.play(BytesSource(bytes));
    } catch (_) {
      // Abaikan error audio — game tetap jalan tanpa suara
    }
  }

  // ── BGM ──────────────────────────────────────────────────────

  /// Mulai background music (loop). Aman dipanggil berkali-kali.
  Future<void> startBgm() async {
    if (_bgmPlaying || _isMuted || !_bgmEnabled) return;

    try {
      await _bgmPlayer?.stop();
      _bgmPlayer?.dispose();
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(_volume * 0.3);

      try {
        // Coba mainkan file mp3 custom dari assets terlebih dahulu
        await _bgmPlayer!.play(AssetSource('audio/backsound.mp3'));
        _bgmPlaying = true;
      } catch (e) {
        // Jika file tidak ada, gunakan backsound bawaan (sintetis)
        final bytes = SoundGenerator.getSound(SoundType.bgm);
        await _bgmPlayer!.play(BytesSource(bytes));
        _bgmPlaying = true;
      }
    } catch (_) {
      // Abaikan — bisa jadi platform tidak support
    }
  }

  /// Hentikan background music sepenuhnya.
  Future<void> stopBgm() async {
    _bgmPlaying = false;
    try {
      await _bgmPlayer?.pause();
      await _bgmPlayer?.release();
      _bgmPlayer?.dispose();
      _bgmPlayer = null;
    } catch (_) {}
  }

  // ── Settings ─────────────────────────────────────────────────

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    try {
      _bgmPlayer?.setVolume(_volume * 0.3);
    } catch (_) {}
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    try {
      if (muted) {
        stopBgm();
      } else if (_bgmEnabled) {
        startBgm();
      }
    } catch (_) {}
  }

  void setSfxEnabled(bool enabled) {
    _sfxEnabled = enabled;
  }

  void setBgmEnabled(bool enabled) {
    _bgmEnabled = enabled;
    try {
      if (!enabled) {
        stopBgm();
      } else if (!_isMuted) {
        startBgm();
      }
    } catch (_) {}
  }

  // ── Getters ──────────────────────────────────────────────────

  bool get isMuted => _isMuted;
  bool get sfxEnabled => _sfxEnabled;
  bool get bgmEnabled => _bgmEnabled;
  double get volume => _volume;

  // ── Dispose ──────────────────────────────────────────────────

  void dispose() {
    for (final player in _sfxPlayers.values) {
      player.dispose();
    }
    _sfxPlayers.clear();
    _bgmPlayer?.dispose();
    _bgmPlayer = null;
    _bgmPlaying = false;
  }
}
