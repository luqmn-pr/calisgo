import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/audio_provider.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_generator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../shared/widgets/settings_dialog.dart';
import '../../competitive/domain/competitive_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Wall and Floor Background ─────────────────────────
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFF9C4), Color(0xFFFFE082)], // Warm wall
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFA1887F), Color(0xFF6D4C41)], // Wood floor
                    ),
                  ),
                ),
              ),
            ],
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
                  // Left module cards
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(right: context.sw(10)),
                      child: _buildModuleSection(context),
                    ),
                  ),

                  SizedBox(width: context.sw(16)),

                  // Right character panel
                  Expanded(flex: 4, child: _buildCharacterPanel(context)),
                ],
              ),
            ),
          ),

          // ── Corner buttons ────────────────────────────
          Positioned(
            top: context.sh(14),
            left: context.sw(14),
            child: GestureDetector(
              onTap: () {
                context.go('/landing');
              },
              child: Container(
                width: context.sw(42),
                height: context.sw(42),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEF5350),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF5350).withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: context.sw(22),
                ),
              ),
            ).animate(delay: 800.ms).fadeIn().scale(),
          ),
          Positioned(
            top: context.sh(14),
            right: context.sw(14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    context.push('/leaderboard');
                  },
                  child: Container(
                    width: context.sw(42),
                    height: context.sw(42),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFB300),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: context.sw(22),
                    ),
                  ),
                ).animate(delay: 850.ms).fadeIn().scale(),
                SizedBox(width: context.sw(12)),
                GestureDetector(
                  onTap: () {
                    SettingsDialog.show(context);
                  },
                  child: Container(
                    width: context.sw(42),
                    height: context.sw(42),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF29B6F6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF29B6F6).withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                      size: context.sw(22),
                    ),
                  ),
                ).animate(delay: 900.ms).fadeIn().scale(),
              ],
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

  // ─── Character panel (right) ──────────────────────────────────────
  Widget _buildCharacterPanel(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, -8 * _floatController.value),
        child: child,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Boy Character
          Container(
            padding: EdgeInsets.only(top: context.sh(40)),
            child: Image.asset(
              'assets/images/char_boy.png',
              height: context.sh(320),
              fit: BoxFit.contain,
            ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.5, end: 0),
          ),
          
          // Speech Bubble
          Positioned(
            top: context.sh(30),
            left: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sw(12),
                vertical: context.sh(8),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Halo Teman!',
                    style: GoogleFonts.nunito(
                      fontSize: context.fs(14),
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0277BD),
                    ),
                  ),
                  SizedBox(height: context.sh(2)),
                  Text(
                    'Ayo kita belajar\nsama-sama!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: context.fs(10),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ).animate(delay: 800.ms).scale(
                  curve: Curves.elasticOut,
                  duration: 600.ms,
                ),
          ),
        ],
      ),
    );
  }

  // ─── Module section (left) ──────────────────────────────────
  Widget _buildModuleSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(16),
        vertical: context.sh(16),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3E2D), // Blackboard dark green
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF5D4037), // Wooden border
          width: 8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Center(
            child: Text(
              'Pilih Pelajaran',
              style: GoogleFonts.nunito(
                fontSize: context.fs(22),
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.95),
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn()
                .slideX(begin: -0.2, end: 0),
          ),

          SizedBox(height: context.sh(12)),

          // Module cards
        Expanded(
          child: Column(
            children: [
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
                  ],
                ),
              ),
              SizedBox(height: context.sh(10)),
              Expanded(
                child: Row(
                  children: [
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
          ),
        ),
      ],
      ),
    );
  }
}

// ─── Module Card ─────────────────────────────────────────────────
class _ModuleCard extends ConsumerStatefulWidget {
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
  ConsumerState<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends ConsumerState<_ModuleCard>
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
            if (widget.route == '/competitive') {
              _showTeamNameDialog(context);
            } else {
              context.push(widget.route);
            }
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
              alignment: Alignment.center,
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
                        width: context.sw(75),
                        height: context.sw(75),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.25),
                        ),
                        child: Center(
                          child: Text(
                            widget.emoji,
                            style: TextStyle(fontSize: context.sw(42)),
                          ),
                        ),
                      ),
                      SizedBox(height: context.sh(12)),
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

  void _showTeamNameDialog(BuildContext context) {
    final blueCtrl = TextEditingController(text: 'Tim Biru');
    final redCtrl = TextEditingController(text: 'Tim Merah');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Nama Tim',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: blueCtrl,
                decoration: InputDecoration(
                  labelText: 'Tim Kiri (Biru)',
                  labelStyle: TextStyle(color: AppColors.teamBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person, color: AppColors.teamBlue),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: redCtrl,
                decoration: InputDecoration(
                  labelText: 'Tim Kanan (Merah)',
                  labelStyle: TextStyle(color: AppColors.teamRed),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person, color: AppColors.teamRed),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.competitiveColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(competitiveProvider.notifier).setTeamNames(
                      blueCtrl.text.isEmpty ? 'Tim Biru' : blueCtrl.text,
                      redCtrl.text.isEmpty ? 'Tim Merah' : redCtrl.text,
                    );
                context.push(widget.route);
              },
              child: Text(
                'Mulai Pertarungan!',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
