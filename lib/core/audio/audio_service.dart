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
      _bgmPlayer?.dispose();
      _bgmPlayer = AudioPlayer();
      await _bgmPlayer!.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer!.setVolume(_volume * 0.3);

      final bytes = SoundGenerator.getSound(SoundType.bgm);
      await _bgmPlayer!.play(BytesSource(bytes));
      _bgmPlaying = true;
    } catch (_) {
      // Abaikan — bisa jadi platform tidak support BytesSource
    }
  }

  /// Hentikan background music sepenuhnya.
  Future<void> stopBgm() async {
    _bgmPlaying = false;
    try {
      await _bgmPlayer?.stop();
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
        _bgmPlayer?.pause();
      } else if (_bgmEnabled && _bgmPlaying) {
        _bgmPlaying = false;
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
        _bgmPlayer?.pause();
      } else if (!_isMuted && _bgmPlaying) {
        _bgmPlaying = false;
        startBgm();
      } else if (!_isMuted && !_bgmPlaying) {
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
