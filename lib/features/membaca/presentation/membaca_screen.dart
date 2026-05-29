import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_sizes.dart';
import '../data/membaca_data.dart';
import '../domain/membaca_provider.dart';

class MembacaScreen extends ConsumerWidget {
  const MembacaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(membacaProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset('assets/images/module_bg.png', fit: BoxFit.cover),
          Container(
            color: AppColors.membacaColor.withOpacity(0.15),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, ref, state),
                Expanded(
                  child: state.mode == MembacaMode.huruf
                      ? _HurufView(state: state, ref: ref)
                      : _KataView(state: state, ref: ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, WidgetRef ref, MembacaState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(16),
        vertical: context.sh(8),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.membacaColor, const Color(0xFFE64A19)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.membacaColor.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ),
          SizedBox(width: context.sw(12)),
          Text('📖', style: TextStyle(fontSize: context.sw(24))),
          SizedBox(width: context.sw(8)),
          Text(
            'Membaca',
            style: GoogleFonts.nunito(
              fontSize: context.fs(18),
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          _ModeToggle(
            currentMode: state.mode,
            onChanged: (m) => ref.read(membacaProvider.notifier).setMode(m),
          ),
          SizedBox(width: context.sw(12)),
          _ScoreChip(score: state.score, color: AppColors.membacaColor),
        ],
      ),
    );
  }
}

// ── Mode Toggle ──────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final MembacaMode currentMode;
  final ValueChanged<MembacaMode> onChanged;
  const _ModeToggle({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _ToggleChip(
            label: 'Huruf',
            icon: '🔤',
            isActive: currentMode == MembacaMode.huruf,
            onTap: () => onChanged(MembacaMode.huruf),
          ),
          _ToggleChip(
            label: 'Kata',
            icon: '📝',
            isActive: currentMode == MembacaMode.kata,
            onTap: () => onChanged(MembacaMode.kata),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label, icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleChip(
      {required this.label,
      required this.icon,
      required this.isActive,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: context.sw(12),
          vertical: context.sh(5),
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(icon, style: TextStyle(fontSize: context.sw(14))),
            SizedBox(width: context.sw(4)),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: isActive ? AppColors.membacaColor : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: context.fs(13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Score chip ───────────────────────────────────────────────────
class _ScoreChip extends StatelessWidget {
  final int score;
  final Color color;
  const _ScoreChip({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sw(14),
        vertical: context.sh(6),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          SizedBox(width: context.sw(6)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              '$score',
              key: ValueKey(score),
              style: GoogleFonts.nunito(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: context.fs(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navigation button ────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.sw(8)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: context.sw(18)),
      ),
    );
  }
}

// ─── Huruf View ─────────────────────────────────────────────────
class _HurufView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;
  const _HurufView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final huruf = MembacaData.hurufAZ[state.currentIndex];

    return Row(
      children: [
        _ArrowBtn(
          icon: Icons.chevron_left_rounded,
          onTap: () => ref.read(membacaProvider.notifier).prevHuruf(),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HurufCard(huruf: huruf, ref: ref)
                    .animate(key: ValueKey(state.currentIndex))
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(duration: 300.ms),
                SizedBox(width: context.sw(32)),
                _ContohCard(huruf: huruf)
                    .animate(key: ValueKey('c${state.currentIndex}'))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
        _ArrowBtn(
          icon: Icons.chevron_right_rounded,
          onTap: () => ref.read(membacaProvider.notifier).nextHuruf(),
        ),
      ],
    );
  }
}

class _HurufCard extends StatelessWidget {
  final HurufModel huruf;
  final WidgetRef ref;
  const _HurufCard({required this.huruf, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref.read(membacaProvider.notifier).toggleAnswer(),
      child: Container(
        width: context.sw(170),
        height: context.sh(180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.sw(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.membacaColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              huruf.huruf,
              style: GoogleFonts.nunito(
                fontSize: context.fs(80),
                fontWeight: FontWeight.w900,
                color: AppColors.membacaColor,
                height: 1,
              ),
            ),
            Text(
              huruf.hurufKecil,
              style: GoogleFonts.nunito(
                fontSize: context.fs(40),
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
                height: 1,
              ),
            ),
            SizedBox(height: context.sh(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.sw(10),
                vertical: context.sh(3),
              ),
              decoration: BoxDecoration(
                color: AppColors.membacaColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Tap untuk contoh',
                style: GoogleFonts.nunito(
                  fontSize: context.fs(10),
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContohCard extends StatelessWidget {
  final HurufModel huruf;
  const _ContohCard({required this.huruf});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sw(150),
      height: context.sh(175),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.membacaColor.withOpacity(0.12),
            AppColors.membacaColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(context.sw(20)),
        border: Border.all(
          color: AppColors.membacaColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(huruf.emoji,
              style: TextStyle(fontSize: context.sw(56))),
          SizedBox(height: context.sh(8)),
          Text(
            huruf.contohKata,
            style: GoogleFonts.nunito(
              fontSize: context.fs(20),
              color: AppColors.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: context.sh(4)),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: huruf.huruf,
                style: GoogleFonts.nunito(
                  color: AppColors.membacaColor,
                  fontWeight: FontWeight.w900,
                  fontSize: context.fs(14),
                ),
              ),
              TextSpan(
                text: huruf.contohKata.substring(1).toLowerCase(),
                style: GoogleFonts.nunito(
                  color: AppColors.textMedium,
                  fontSize: context.fs(14),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.sw(8)),
        padding: EdgeInsets.all(context.sw(12)),
        decoration: BoxDecoration(
          color: AppColors.membacaColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.membacaColor.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.membacaColor,
          size: context.sw(28),
        ),
      ),
    );
  }
}

// ─── Kata View ──────────────────────────────────────────────────
class _KataView extends StatelessWidget {
  final MembacaState state;
  final WidgetRef ref;
  const _KataView({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final kata = MembacaData.kataLatihan[state.currentIndex];

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kata.emoji,
                style: TextStyle(fontSize: context.sw(64)),
              )
                  .animate(key: ValueKey(state.currentIndex))
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    curve: Curves.elasticOut,
                  ),

              SizedBox(height: context.sh(10)),

              Text(
                'Susun suku kata berikut!',
                style: GoogleFonts.nunito(
                  fontSize: context.fs(16),
                  color: AppColors.textMedium,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: context.sh(16)),

              // Drop zone
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(kata.sukuKata.length, (i) {
                  return _DropSlot(
                    content: i < state.arrangedSukuKata.length
                        ? state.arrangedSukuKata[i]
                        : null,
                    isCorrect: state.isCorrect,
                    onRemove: i < state.arrangedSukuKata.length
                        ? () => ref
                            .read(membacaProvider.notifier)
                            .removeSukuKata(state.arrangedSukuKata[i])
                        : null,
                  );
                }),
              ),

              SizedBox(height: context.sh(20)),

              // Source suku kata
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: state.shuffledSukuKata.map((suku) {
                  final totalInSource =
                      kata.sukuKata.where((s) => s == suku).length;
                  final usedCount =
                      state.arrangedSukuKata.where((s) => s == suku).length;
                  final used = usedCount >= totalInSource;
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: context.sw(8)),
                    child: GestureDetector(
                      onTap: used
                          ? null
                          : () => ref
                              .read(membacaProvider.notifier)
                              .pickSukuKata(suku),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.sw(20),
                          vertical: context.sh(10),
                        ),
                        decoration: BoxDecoration(
                          color:
                              used ? Colors.grey.shade300 : AppColors.membacaColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: used
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.membacaColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Text(
                          suku,
                          style: GoogleFonts.nunito(
                            color: used ? Colors.grey.shade500 : Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: context.fs(20),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: context.sh(16)),

              if (state.isCorrect)
                Column(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 40))
                        .animate()
                        .scale(curve: Curves.elasticOut),
                    Text(
                      'Hebat! ${kata.kata} ✓',
                      style: GoogleFonts.nunito(
                        fontSize: context.fs(20),
                        color: AppColors.correct,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: context.sh(10)),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(membacaProvider.notifier).nextKata(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.membacaColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Kata Berikutnya →',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        // Dot progress
        Positioned(
          bottom: context.sh(12),
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              MembacaData.kataLatihan.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    EdgeInsets.symmetric(horizontal: context.sw(3)),
                width: i == state.currentIndex ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == state.currentIndex
                      ? AppColors.membacaColor
                      : AppColors.membacaColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropSlot extends StatelessWidget {
  final String? content;
  final bool isCorrect;
  final VoidCallback? onRemove;
  const _DropSlot({this.content, required this.isCorrect, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: context.sw(8)),
        width: context.sw(90),
        height: context.sh(60),
        decoration: BoxDecoration(
          color: content != null
              ? (isCorrect ? AppColors.correct : AppColors.primary)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: content != null
                ? Colors.transparent
                : AppColors.membacaColor.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: content != null
              ? [
                  BoxShadow(
                    color:
                        (isCorrect ? AppColors.correct : AppColors.primary)
                            .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            content ?? '?',
            style: GoogleFonts.nunito(
              color: content != null
                  ? Colors.white
                  : AppColors.membacaColor.withOpacity(0.4),
              fontWeight: FontWeight.w900,
              fontSize: context.fs(22),
            ),
          ),
        ),
      ),
    );
  }
}
