import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_sizes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoController.forward();

    // Navigate to landing after 3s
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) context.go('/landing');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Generated background image ─────────────────
          Image.asset(
            'assets/images/landing_bg.png',
            fit: BoxFit.cover,
          ),

          // ── Dark overlay for better contrast ───────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),

          // ── Characters ─────────────────────────────────
          Positioned(
            left: -context.sw(20),
            bottom: -context.sh(20),
            child: Image.asset(
              'assets/images/char_girl.png',
              height: context.sh(350),
              fit: BoxFit.contain,
            ).animate(delay: 400.ms).fadeIn(duration: 800.ms).slideX(
                  begin: -0.2,
                  end: 0,
                  curve: Curves.easeOutCubic,
                ),
          ),
          Positioned(
            right: -context.sw(20),
            bottom: -context.sh(20),
            child: Image.asset(
              'assets/images/char_boy.png',
              height: context.sh(350),
              fit: BoxFit.contain,
            ).animate(delay: 500.ms).fadeIn(duration: 800.ms).slideX(
                  begin: 0.2,
                  end: 0,
                  curve: Curves.easeOutCubic,
                ),
          ),

          // ── Floating sparkle decorations ───────────────
          ..._buildSparkles(size),

          // ── Main content ───────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                ScaleTransition(
                  scale: _logoScale,
                  child: _buildLogo(context),
                ),

                SizedBox(height: context.sh(24)),

                // CALISTUNG colorful title
                _buildCalistungTitle(context),

                SizedBox(height: context.sh(8)),

                // Sub title
                Text(
                  'Belajar Sambil Bermain!',
                  style: GoogleFonts.nunito(
                    fontSize: context.fs(16),
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(1, 2),
                      ),
                    ],
                  ),
                )
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                SizedBox(height: context.sh(28)),

                // Loading indicator
                _buildLoadingBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sw(28)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.5 * _glowAnim.value),
              blurRadius: 40,
              spreadRadius: 10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.3 * _glowAnim.value),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: child,
      ),
      child: Container(
        width: context.sw(130),
        height: context.sw(130),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sw(28)),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.sw(25)),
          child: Image.asset(
            'assets/images/app_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildCalistungTitle(BuildContext context) {
    const letters = [
      ('C', Color(0xFFEF5350)),
      ('A', Color(0xFFFF9800)),
      ('L', Color(0xFFFFEB3B)),
      ('I', Color(0xFF66BB6A)),
      ('S', Color(0xFF40C4FF)),
      ('G', Color(0xFF7E57C2)),
      ('O', Color(0xFFEC407A)),
    ];
    final fs = context.fs(52);

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
                color: Colors.black.withOpacity(0.35),
                blurRadius: 4,
                offset: const Offset(2, 3),
              ),
              Shadow(
                color: e.value.$2.withOpacity(0.6),
                blurRadius: 12,
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 400 + e.key * 70))
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.6, end: 0, curve: Curves.easeOut);
      }).toList(),
    );
  }

  Widget _buildLoadingBar(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: context.sw(200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ).animate(delay: 1200.ms).fadeIn(),
        SizedBox(height: context.sh(8)),
        Text(
          'Memuat...',
          style: GoogleFonts.nunito(
            fontSize: context.fs(13),
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ).animate(delay: 1200.ms).fadeIn(),
      ],
    );
  }

  List<Widget> _buildSparkles(Size size) {
    final sparkles = [
      _SparkleData(top: 0.08, left: 0.05, size: 28, delay: 200),
      _SparkleData(top: 0.12, right: 0.08, size: 22, delay: 500),
      _SparkleData(top: 0.75, left: 0.1, size: 18, delay: 300),
      _SparkleData(top: 0.8, right: 0.06, size: 24, delay: 700),
      _SparkleData(top: 0.35, left: 0.03, size: 16, delay: 900),
      _SparkleData(top: 0.55, right: 0.04, size: 20, delay: 100),
    ];

    return sparkles.map((s) {
      return Positioned(
        top: s.top != null ? size.height * s.top! : null,
        left: s.left != null ? size.width * s.left! : null,
        right: s.right != null ? size.width * s.right! : null,
        child: Text(
          '✨',
          style: TextStyle(fontSize: s.size.toDouble()),
        )
            .animate(
              delay: Duration(milliseconds: s.delay),
              onPlay: (c) => c.repeat(reverse: true),
            )
            .fadeIn(duration: 600.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: 1200.ms,
              curve: Curves.easeInOut,
            ),
      );
    }).toList();
  }
}

class _SparkleData {
  final double? top, left, right;
  final int size, delay;
  const _SparkleData({
    this.top,
    this.left,
    this.right,
    required this.size,
    required this.delay,
  });
}
