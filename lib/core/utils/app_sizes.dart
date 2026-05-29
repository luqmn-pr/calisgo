import 'package:flutter/material.dart';

/// Samsung Galaxy S25 FE target:
/// Physical: 2340 x 1080 px
/// Device pixel ratio: ~2.4
/// Logical landscape: ~975 x 450 dp
///
/// Semua ukuran UI di-scale relatif terhadap baseline ini
/// agar mudah diubah ke responsive di masa depan.
class AppSizes {
  AppSizes._();

  // ── Baseline target (S25 FE landscape) ────────────────────
  static const double baseWidth = 975.0;
  static const double baseHeight = 450.0;

  // ── Shorthand builder ──────────────────────────────────────
  static double w(BuildContext context, double fraction) =>
      MediaQuery.of(context).size.width * fraction;

  static double h(BuildContext context, double fraction) =>
      MediaQuery.of(context).size.height * fraction;

  /// Scale a value designed for baseWidth to current screen width
  static double sw(BuildContext context, double designValue) =>
      designValue / baseWidth * MediaQuery.of(context).size.width;

  /// Scale a value designed for baseHeight to current screen height
  static double sh(BuildContext context, double designValue) =>
      designValue / baseHeight * MediaQuery.of(context).size.height;

  // ── Font sizes (designed for baseWidth) ───────────────────
  static double fontSize(BuildContext context, double size) {
    final scale =
        MediaQuery.of(context).size.width / baseWidth;
    return (size * scale).clamp(size * 0.7, size * 1.3);
  }

  // ── Common paddings ────────────────────────────────────────
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: sw(context, 24),
        vertical: sh(context, 16),
      );
}

extension ContextSize on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double sw(double v) => AppSizes.sw(this, v);
  double sh(double v) => AppSizes.sh(this, v);
  double fs(double v) => AppSizes.fontSize(this, v);
}
