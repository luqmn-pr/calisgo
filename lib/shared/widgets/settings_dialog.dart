import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/audio/audio_provider.dart';
import '../../core/audio/audio_service.dart';
import '../../core/audio/sound_generator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_sizes.dart';

/// Dialog pengaturan yang child-friendly.
///
/// Menampilkan kontrol volume, toggle efek suara, toggle musik latar,
/// dan informasi aplikasi.
class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  /// Tampilkan dialog pengaturan.
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(audioSettingsProvider);
    final notifier = ref.read(audioSettingsProvider.notifier);
    final audioService = ref.read(audioServiceProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.background,
      child: Container(
        width: context.sw(340),
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(24),
          vertical: context.sh(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⚙️', style: TextStyle(fontSize: context.fs(26))),
                SizedBox(width: context.sw(8)),
                Text(
                  'Pengaturan',
                  style: GoogleFonts.nunito(
                    fontSize: context.fs(22),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sh(18)),

            // ── Volume Slider ──────────────────────────
            _SettingTile(
              emoji: settings.isMuted ? '🔇' : '🔊',
              label: 'Volume',
              trailing: SizedBox(
                width: context.sw(160),
                child: Row(
                  children: [
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primaryLight,
                          thumbColor: AppColors.primaryDark,
                          overlayColor: AppColors.primary.withOpacity(0.2),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: settings.volume,
                          onChanged: settings.isMuted
                              ? null
                              : (v) => notifier.setVolume(v),
                          onChangeEnd: (_) {
                            audioService.playSound(SoundType.pop);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        notifier.toggleMute();
                        audioService.playSound(SoundType.tap);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          settings.isMuted
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: settings.isMuted
                              ? AppColors.incorrect
                              : AppColors.primary,
                          size: context.sw(22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.sh(8)),

            // ── SFX Toggle ─────────────────────────────
            _SettingTile(
              emoji: '🎵',
              label: 'Efek Suara',
              trailing: Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: settings.sfxEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (_) {
                    notifier.toggleSfx();
                    audioService.playSound(SoundType.tap);
                  },
                ),
              ),
            ),
            SizedBox(height: context.sh(8)),

            // ── BGM Toggle ─────────────────────────────
            _SettingTile(
              emoji: '🎶',
              label: 'Musik Latar',
              trailing: Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: settings.bgmEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (_) => notifier.toggleBgm(),
                ),
              ),
            ),
            SizedBox(height: context.sh(16)),

            // ── Close Button ───────────────────────────
            SizedBox(
              width: context.sw(140),
              child: ElevatedButton.icon(
                onPressed: () {
                  audioService.playSound(SoundType.tap);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: Text(
                  'Tutup',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: context.fs(14),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: context.sh(10)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baris setting individual dengan emoji, label, dan trailing widget.
class _SettingTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Widget trailing;

  const _SettingTile({
    required this.emoji,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(14),
        vertical: context.sh(6),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: context.fs(20))),
          SizedBox(width: context.sw(10)),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: context.fs(14),
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
