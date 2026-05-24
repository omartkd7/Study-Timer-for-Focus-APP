import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary    = Color(0xFF6C63FF);
  static const primaryDark= Color(0xFF4E46E5);
  static const accent     = Color(0xFFFF6584);
  static const success    = Color(0xFF22C55E);
  static const warning    = Color(0xFFF59E0B);
  static const info       = Color(0xFF3B82F6);
  static const focus      = Color(0xFF6C63FF);
  static const shortBreak = Color(0xFF22C55E);
  static const longBreak  = Color(0xFF3B82F6);
  static const dark       = Color(0xFF0F0F1A);
  static const darkSurface= Color(0xFF1A1A2E);
  static const darkCard   = Color(0xFF16213E);
  static const light      = Color(0xFFF8F8FF);
  static const lightCard  = Color(0xFFF1F0FF);
}

class SubjectColors {
  static const _palette = {
    'Study':    Color(0xFF6C63FF),
    'Math':     Color(0xFFEF4444),
    'Science':  Color(0xFF14B8A6),
    'Language': Color(0xFFF59E0B),
    'Coding':   Color(0xFF10B981),
    'Reading':  Color(0xFF3B82F6),
    'History':  Color(0xFFFF7849),
    'Art':      Color(0xFFD946EF),
    'Other':    Color(0xFF94A3B8),
  };

  static Color of(String subject) => _palette[subject] ?? AppColors.primary;
}

class AppTheme {
  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: dark ? AppColors.dark : AppColors.light,
      colorScheme: ColorScheme(
        brightness: b,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: dark ? AppColors.darkSurface : Colors.white,
        onSurface: dark ? Colors.white : const Color(0xFF1A1A2E),
      ),
      textTheme: GoogleFonts.interTextTheme(
          dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      cardTheme: CardThemeData(
        color: dark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.dark : AppColors.light,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w600,
          color: dark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
