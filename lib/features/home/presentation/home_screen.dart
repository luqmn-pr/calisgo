import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8E1), Color(0xFFE1F5FE), Color(0xFFF3E5F5)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Left Panel — Branding
              Expanded(flex: 3, child: _buildBrandPanel(context)),
              // Right Panel — Module Cards
              Expanded(flex: 7, child: _buildModuleGrid(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.primaryDark.withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo / Icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('📚', style: TextStyle(fontSize: 48)),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 20),

          Text(
            'ProjectTK',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3, end: 0),

          const SizedBox(height: 8),

          Text(
            'Belajar Calistung\nMenjadi Menyenangkan!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.3, end: 0),

          const SizedBox(height: 32),

          // Stars decoration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['⭐', '⭐', '⭐']
                .asMap()
                .entries
                .map(
                  (e) => Text(e.value, style: const TextStyle(fontSize: 24))
                      .animate(delay: Duration(milliseconds: 600 + e.key * 150))
                      .scale(curve: Curves.elasticOut),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context) {
    final modules = [
      _ModuleInfo(
        emoji: '📖',
        title: 'Membaca',
        subtitle: 'Mengenal Huruf & Kata',
        color: AppColors.membacaColor,
        route: '/membaca',
        delay: 0,
      ),
      _ModuleInfo(
        emoji: '✏️',
        title: 'Menulis',
        subtitle: 'Menebalkan Huruf',
        color: AppColors.menulisColor,
        route: '/menulis',
        delay: 100,
      ),
      _ModuleInfo(
        emoji: '🔢',
        title: 'Berhitung',
        subtitle: 'Menghitung & Menjumlah',
        color: AppColors.berhitungColor,
        route: '/berhitung',
        delay: 200,
      ),
      _ModuleInfo(
        emoji: '⚔️',
        title: 'Kompetisi',
        subtitle: '2 Tim — 1 Layar',
        color: AppColors.competitiveColor,
        route: '/competitive',
        delay: 300,
        isSpecial: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pilih Pelajaran',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: modules
                  .map(
                    (m) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _ModuleCard(module: m),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleInfo {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final String route;
  final int delay;
  final bool isSpecial;

  const _ModuleInfo({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
    required this.delay,
    this.isSpecial = false,
  });
}

class _ModuleCard extends StatefulWidget {
  final _ModuleInfo module;
  const _ModuleCard({required this.module});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnim.value, child: child),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isHovered = true);
          _hoverController.forward();
        },
        onTapUp: (_) {
          setState(() => _isHovered = false);
          _hoverController.reverse();
          context.push(widget.module.route);
        },
        onTapCancel: () {
          setState(() => _isHovered = false);
          _hoverController.reverse();
        },
        child:
            AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.module.color,
                        widget.module.color.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.module.color.withOpacity(
                          _isHovered ? 0.6 : 0.3,
                        ),
                        blurRadius: _isHovered ? 24 : 12,
                        offset: Offset(0, _isHovered ? 8 : 4),
                      ),
                    ],
                    border: widget.module.isSpecial
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.module.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.module.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.module.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.module.isSpecial) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🏆 Mode Seru!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                .animate(
                  delay: Duration(milliseconds: widget.module.delay + 300),
                )
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
      ),
    );
  }
}
