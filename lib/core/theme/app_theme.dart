// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F9FB), // Soft Grey
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4A90E2), // Soft Blue
        primary: const Color(0xFF4A90E2),
        secondary: const Color(0xFF7FB3D5),
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }
}
