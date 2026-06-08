import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../shared/widgets/settings_dialog.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _floatController;
  late AnimationController _btnPulseController;
  late AnimationController _charController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _btnPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _charController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start background music
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).startBgm();
    });
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _floatController.dispose();
    _btnPulseController.dispose();
    _charController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Generated background ─────────────────────
          Image.asset('assets/images/landing_bg.png', fit: BoxFit.cover),

          // ── 3. Stars & sparkle decorations ─────────────
          _buildDecorations(size),

          // ── 4. Girl character (left) ────────────────────
          _buildGirlCharacter(size),

          // ── 5. Boy character (right) ────────────────────
          _buildBoyCharacter(size),

          // ── 6. Center content (title + button) ─────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: context.sh(16)),
                _buildCalistungTitle(context),
                SizedBox(height: context.sh(6)),
                _buildSubtitle(context),
                SizedBox(height: context.sh(20)),
                _buildPlayButton(context),
              ],
            ),
          ),

          // ── 7. Corner UI buttons ─────────────────────────
          _buildCornerButtons(context),
        ],
      ),
    );
  }

  // ─── Animated clouds overlay ──────────────────────────────────
  Widget _buildAnimatedClouds(Size size) {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (_, __) {
        final drift = _cloudController.value * size.width * 0.08;
        return Stack(
          children: [
            Positioned(
              top: size.height * 0.04,
              left: size.width * 0.06 + drift,
              child: _cloudWidget(120, 44),
            ),
            Positioned(
              top: size.height * 0.02,
              left: size.width * 0.25 + drift * 0.7,
              child: _cloudWidget(90, 34),
            ),
            Positioned(
              top: size.height * 0.06,
              right: size.width * 0.08 - drift * 0.5,
              child: _cloudWidget(140, 50),
            ),
          ],
        );
      },
    );
  }

  Widget _cloudWidget(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.82),
        borderRadius: BorderRadius.circular(h / 2),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 16),
        ],
      ),
    );
  }

  // ─── Floating decorations ───────────────────────────────────
  Widget _buildDecorations(Size size) {
    return Stack(
      children: [
        Positioned(
          top: size.height * 0.06,
          left: size.width * 0.42,
          child: const Text('⭐', style: TextStyle(fontSize: 18))
              .animate(delay: 300.ms, onPlay: (c) => c.repeat(reverse: true))
              .fadeIn()
              .moveY(begin: 0, end: -8, duration: 1500.ms),
        ),
        Positioned(
          top: size.height * 0.1,
          right: size.width * 0.42,
          child: const Text('✨', style: TextStyle(fontSize: 16))
              .animate(delay: 600.ms, onPlay: (c) => c.repeat(reverse: true))
              .fadeIn()
              .moveY(begin: 0, end: -6, duration: 1200.ms),
        ),
      ],
    );
  }

  // ─── Girl character ────────────────────────────────────────
  Widget _buildGirlCharacter(Size size) {
    return Positioned(
      bottom: size.height * 0.05,
      left: size.width * 0.04,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -10 * _floatController.value),
          child: child,
        ),
        child:
            Image.asset(
                  'assets/images/char_girl.png',
                  height: size.height * 0.72,
                  fit: BoxFit.contain,
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 700.ms)
                .slideX(begin: -0.5, end: 0, curve: Curves.easeOut),
      ),
    );
  }

  // ─── Boy character ────────────────────────────────────────
  Widget _buildBoyCharacter(Size size) {
    return Positioned(
      bottom: size.height * 0.05,
      right: size.width * 0.04,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -10 * (1 - _floatController.value)),
          child: child,
        ),
        child:
            Image.asset(
                  'assets/images/char_boy.png',
                  height: size.height * 0.72,
                  fit: BoxFit.contain,
                )
                .animate(delay: 500.ms)
                .fadeIn(duration: 700.ms)
                .slideX(begin: 0.5, end: 0, curve: Curves.easeOut),
      ),
    );
  }

  // ─── CALISTUNG colorful title ──────────────────────────────
  Widget _buildCalistungTitle(BuildContext context) {
    const letters = [
      ('C', Color(0xFFEF5350)),
      ('A', Color(0xFFFF9800)),
      ('L', Color(0xFFFDD835)),
      ('I', Color(0xFF66BB6A)),
      ('S', Color(0xFF29B6F6)),
      ('G', Color(0xFF7E57C2)),
      ('O', Color(0xFFEC407A)),
    ];
    final fs = context.fs(48);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: letters.asMap().entries.map((e) {
        return Text(
              e.value.$1,
              style: GoogleFonts.nunito(
                fontSize: fs,
                fontWeight: FontWeight.w900,
                color: e.value.$2,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 3),
                  ),
                  Shadow(color: e.value.$2.withOpacity(0.5), blurRadius: 10),
                ],
              ),
            )
            .animate(delay: Duration(milliseconds: 200 + e.key * 60))
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.5, end: 0, curve: Curves.easeOut);
      }).toList(),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(16),
        vertical: context.sh(4),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Membaca  –  Menulis  –  Berhitung',
        style: GoogleFonts.nunito(
          fontSize: context.fs(14),
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 500.ms);
  }

  // ─── Play button ───────────────────────────────────────────
  Widget _buildPlayButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _btnPulseController,
      builder: (_, child) {
        final glow = 16.0 + _btnPulseController.value * 20;
        final scale = 1.0 + _btnPulseController.value * 0.04;
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB300).withOpacity(0.7),
                  blurRadius: glow,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: glow * 0.5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          context.go('/');
        },
        child:
            Container(
                  width: context.sw(92),
                  height: context.sw(92),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFFFF176), Color(0xFFFFB300)],
                      center: Alignment(-0.3, -0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: context.sw(50),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                )
                .animate(delay: 800.ms)
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),
      ),
    );
  }

  // ─── Corner buttons ────────────────────────────────────────
  Widget _buildCornerButtons(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: context.sh(14),
          left: context.sw(14),
          child: _CircleIconBtn(
            icon: Icons.settings_rounded,
            color: const Color(0xFF29B6F6),
            size: context.sw(42),
            onTap: () {
              SettingsDialog.show(context);
            },
          ).animate(delay: 1000.ms).fadeIn().scale(),
        ),
        Positioned(
          top: context.sh(66),
          left: context.sw(14),
          child: Consumer(
            builder: (context, ref, _) {
              final isMuted = ref.watch(audioSettingsProvider).isMuted;
              return _CircleIconBtn(
                icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: isMuted ? const Color(0xFF9E9E9E) : const Color(0xFFFF9800),
                size: context.sw(42),
                onTap: () {
                  ref.read(audioSettingsProvider.notifier).toggleMute();
                },
              );
            },
          ).animate(delay: 1100.ms).fadeIn().scale(),
        ),
        Positioned(
          top: context.sh(14),
          right: context.sw(14),
          child: _CircleIconBtn(
            icon: Icons.close_rounded,
            color: const Color(0xFFEF5350),
            size: context.sw(42),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: const Color(0xFFFFF8E1),
                  title: Text('👋 Keluar?', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 22)),
                  content: Text('Yakin ingin keluar dari Calisgo?', style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Tidak', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: const Color(0xFF29B6F6))),
                    ),
                    ElevatedButton(
                      onPressed: () => SystemNavigator.pop(),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('Ya, Keluar', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              );
            },
          ).animate(delay: 1000.ms).fadeIn().scale(),
        ),
      ],
    );
  }
}

// ── Reusable circle icon button ────────────────────────────────
class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _CircleIconBtn({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.52),
      ),
    );
  }
}
