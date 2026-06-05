import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_service.dart';

// ── SharedPreferences Provider ─────────────────────────────────
// Di-override di main.dart via ProviderScope.overrides
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider harus di-override');
});

// ── Audio Service Provider (singleton) ─────────────────────────
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ── Audio Settings State ───────────────────────────────────────
class AudioSettings {
  final bool isMuted;
  final double volume;
  final bool sfxEnabled;
  final bool bgmEnabled;

  const AudioSettings({
    this.isMuted = false,
    this.volume = 0.7,
    this.sfxEnabled = true,
    this.bgmEnabled = true,
  });

  AudioSettings copyWith({
    bool? isMuted,
    double? volume,
    bool? sfxEnabled,
    bool? bgmEnabled,
  }) {
    return AudioSettings(
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
    );
  }
}

// ── Audio Settings Notifier ────────────────────────────────────
class AudioSettingsNotifier extends StateNotifier<AudioSettings> {
  final SharedPreferences _prefs;
  final AudioService _audioService;

  AudioSettingsNotifier(this._prefs, this._audioService)
      : super(const AudioSettings()) {
    _load();
  }

  void _load() {
    state = AudioSettings(
      isMuted: _prefs.getBool('audio_muted') ?? false,
      volume: _prefs.getDouble('audio_volume') ?? 0.7,
      sfxEnabled: _prefs.getBool('audio_sfx') ?? true,
      bgmEnabled: _prefs.getBool('audio_bgm') ?? true,
    );
    _sync();
  }

  void _sync() {
    _audioService.setMuted(state.isMuted);
    _audioService.setVolume(state.volume);
    _audioService.setSfxEnabled(state.sfxEnabled);
    _audioService.setBgmEnabled(state.bgmEnabled);
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
    _prefs.setBool('audio_muted', state.isMuted);
    _sync();
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
    _prefs.setDouble('audio_volume', volume);
    _sync();
  }

  void toggleSfx() {
    state = state.copyWith(sfxEnabled: !state.sfxEnabled);
    _prefs.setBool('audio_sfx', state.sfxEnabled);
    _sync();
  }

  void toggleBgm() {
    state = state.copyWith(bgmEnabled: !state.bgmEnabled);
    _prefs.setBool('audio_bgm', state.bgmEnabled);
    _sync();
  }
}

// ── Audio Settings Provider ────────────────────────────────────
final audioSettingsProvider =
    StateNotifierProvider<AudioSettingsNotifier, AudioSettings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final audioService = ref.watch(audioServiceProvider);
  return AudioSettingsNotifier(prefs, audioService);
});
