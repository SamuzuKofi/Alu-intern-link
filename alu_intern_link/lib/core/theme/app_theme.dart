import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central place for the app's colors and text styles, so every screen
/// looks consistent instead of each widget picking its own colors.
class AppTheme {
  AppTheme._();

  static const Color aluBlue = Color(0xFF1B3A6B);
  static const Color aluGold = Color(0xFFE0A526);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: aluBlue,
      secondary: aluGold,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
    );
  }
}
