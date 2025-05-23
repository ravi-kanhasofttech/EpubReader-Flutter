import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme class that defines the light and dark themes for the application.
/// Uses Material 3 design system and Google Fonts for typography.
class AppTheme {
  /// Returns the light theme configuration for the application.
  /// Uses orange as the seed color and Poppins font family.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.light,
        onPrimary: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  /// Returns the dark theme configuration for the application.
  /// Uses dark grey as the seed color and Poppins font family with dark theme.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.grey.shade900,
        brightness: Brightness.dark,
        onPrimary: Colors.grey.shade900.withValues(alpha: 0.8),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
