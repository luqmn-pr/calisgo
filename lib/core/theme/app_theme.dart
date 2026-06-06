import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Child-friendly color palette for ProjectTK
class AppColors {
  AppColors._();

  // Primary gradient — warm sky blue
  static const Color primary = Color(0xFF4FC3F7);
  static const Color primaryDark = Color(0xFF0288D1);
  static const Color primaryLight = Color(0xFFB3E5FC);

  // Module colors
  static const Color membacaColor = Color(0xFFFF8A65); // Warm orange
  static const Color menulisColor = Color(0xFF81C784); // Fresh green
  static const Color berhitungColor = Color(0xFFBA68C8); // Playful purple
  static const Color competitiveColor = Color(0xFFFFD54F); // Bright yellow

  // Team colors
  static const Color teamBlue = Color(0xFF1E88E5);
  static const Color teamRed = Color(0xFFE53935);

  // Backgrounds
  static const Color background = Color(0xFFFFF8E1); // Warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFF3E0);

  // Text
  static const Color textDark = Color(0xFF37474F);
  static const Color textMedium = Color(0xFF607D8B);
  static const Color textLight = Color(0xFF90A4AE);

  // Feedback
  static const Color correct = Color(0xFF66BB6A);
  static const Color incorrect = Color(0xFFEF5350);
  static const Color neutral = Color(0xFFFFCA28);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.nunito();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: baseText.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
        ),
        displayMedium: baseText.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        headlineLarge: baseText.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        headlineMedium: baseText.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleLarge: baseText.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        bodyLarge: baseText.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyMedium: baseText.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textMedium,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: AppColors.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: baseText.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
