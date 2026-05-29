import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_sizes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _rainbowController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rainbowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Classroom background ─────────────────────────
          Image.asset('assets/images/home_bg.png', fit: BoxFit.cover),

          // ── Warm gradient overlay ────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.22),
                ],
              ),
            ),
          ),

          // ── Bunting flags top ────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildBuntingFlags(context),
          ),

          // ── Main layout ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.sw(20),
                vertical: context.sh(12),
              ),
              child: Row(
                children: [
                  // Left brand panel
                  _buildBrandPanel(context),

                  SizedBox(width: context.sw(16)),

                  // Right module cards
                  Expanded(child: _buildModuleSection(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bunting flags decoration ────────────────────────────────
  Widget _buildBuntingFlags(BuildContext context) {
    const flagColors = [
      Color(0xFFEF5350),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF66BB6A),
      Color(0xFF29B6F6),
      Color(0xFF7E57C2),
      Color(0xFFEC407A),
      Color(0xFFFF7043),
      Color(0xFF26C6DA),
      Color(0xFFEF5350),
      Color(0xFFFF9800),
      Color(0xFFFFEB3B),
      Color(0xFF66BB6A),
    ];

    return SizedBox(
      height: context.sh(28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(flagColors.length, (i) {
          return Container(
            width: context.sw(28),
            height: context.sh(22),
            decoration: BoxDecoration(
              color: flagColors[i],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: flagColors[i].withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ─── Brand panel (left) ──────────────────────────────────────
  Widget _buildBrandPanel(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -4 * _floatController.value),
        child: child,
      ),
      child: Container(
        width: context.sw(190),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sw(24)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF29B6F6), Color(0xFF0277BD)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF29B6F6).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo image
            Container(
              width: context.sw(90),
              height: context.sw(90),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.sw(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.sw(18)),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

            SizedBox(height: context.sh(12)),

            Text(
              'ProjectTK',
              style: GoogleFonts.nunito(
                fontSize: context.fs(22),
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn()
                .slideY(begin: 0.3, end: 0),

            SizedBox(height: context.sh(4)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sw(12)),
              child: Text(
                'Belajar Calistung\nMenjadi Menyenangkan!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: context.fs(11),
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn()
                  .slideY(begin: 0.3, end: 0),
            ),

            SizedBox(height: context.sh(14)),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.sw(3)),
                  child: Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFFFD740),
                    size: context.sw(26),
                  )
                      .animate(delay: Duration(milliseconds: 600 + i * 150))
                      .scale(curve: Curves.elasticOut),
                );
              }),
            ),
          ],
        ),
      ),
    )
        .animate(delay: 100.ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: -0.3, end: 0, curve: Curves.easeOut);
  }

  // ─── Module section (right) ──────────────────────────────────
  Widget _buildModuleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Center(
          child: Text(
            'Pilih Pelajaran',
            style: GoogleFonts.nunito(
              fontSize: context.fs(20),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn()
              .slideX(begin: -0.2, end: 0),
        ),

        SizedBox(height: context.sh(10)),

        // Module cards
        Expanded(
          child: Row(
            children: [
              _ModuleCard(
                emoji: '📖',
                title: 'Membaca',
                subtitle: 'Mengenal\nHuruf & Kata',
                color: AppColors.membacaColor,
                route: '/membaca',
                delay: 0,
                bgColor: const Color(0xFFFF8A65),
                shadowColor: const Color(0xFFD84315),
              ),
              SizedBox(width: context.sw(10)),
              _ModuleCard(
                emoji: '✏️',
                title: 'Menulis',
                subtitle: 'Menebalkan\nHuruf',
                color: AppColors.menulisColor,
                route: '/menulis',
                delay: 80,
                bgColor: const Color(0xFF66BB6A),
                shadowColor: const Color(0xFF2E7D32),
              ),
              SizedBox(width: context.sw(10)),
              _ModuleCard(
                emoji: '🔢',
                title: 'Berhitung',
                subtitle: 'Menghitung\n& Menjumlah',
                color: AppColors.berhitungColor,
                route: '/berhitung',
                delay: 160,
                bgColor: const Color(0xFFAB47BC),
                shadowColor: const Color(0xFF6A1B9A),
              ),
              SizedBox(width: context.sw(10)),
              _ModuleCard(
                emoji: '⚔️',
                title: 'Kompetisi',
                subtitle: '2 Tim —\n1 Layar',
                color: AppColors.competitiveColor,
                route: '/competitive',
                delay: 240,
                bgColor: const Color(0xFFFFD54F),
                shadowColor: const Color(0xFFFF6F00),
                isSpecial: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Module Card ─────────────────────────────────────────────────
class _ModuleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  final int delay;
  final Color bgColor;
  final Color shadowColor;
  final bool isSpecial;

  const _ModuleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    required this.delay,
    required this.bgColor,
    required this.shadowColor,
    this.isSpecial = false,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _pressed = true);
            _pressController.forward();
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            _pressController.reverse();
            context.push(widget.route);
          },
          onTapCancel: () {
            setState(() => _pressed = false);
            _pressController.reverse();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.sw(22)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.bgColor,
                  widget.shadowColor.withOpacity(0.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor.withOpacity(_pressed ? 0.7 : 0.45),
                  blurRadius: _pressed ? 6 : 16,
                  offset: Offset(0, _pressed ? 2 : 8),
                  spreadRadius: _pressed ? 0 : 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
              ],
              border: widget.isSpecial
                  ? Border.all(color: Colors.white.withOpacity(0.7), width: 2.5)
                  : null,
            ),
            child: Stack(
              children: [
                // Shine effect top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: context.sh(50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(context.sw(22)),
                        topRight: Radius.circular(context.sw(22)),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sw(8),
                    vertical: context.sh(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Emoji in circle
                      Container(
                        width: context.sw(60),
                        height: context.sw(60),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: Center(
                          child: Text(
                            widget.emoji,
                            style: TextStyle(fontSize: context.sw(32)),
                          ),
                        ),
                      ),
                      SizedBox(height: context.sh(8)),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: context.fs(16),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.sh(4)),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: context.fs(10),
                          color: Colors.white.withOpacity(0.92),
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.isSpecial) ...[
                        SizedBox(height: context.sh(6)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.sw(8),
                            vertical: context.sh(3),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🏆',
                                  style:
                                      TextStyle(fontSize: context.sw(12))),
                              SizedBox(width: context.sw(4)),
                              Text(
                                'Mode Seru!',
                                style: GoogleFonts.nunito(
                                  fontSize: context.fs(9),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate(
                delay: Duration(milliseconds: widget.delay + 300),
              )
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.4, end: 0, curve: Curves.easeOut),
        ),
      ),
    );
  }
}
