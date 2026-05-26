import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color headingGreen = Color(0xFF2D4A3E);
  static const Color bodyTextGreen = Color(0xFF1E2622);
  static const Color warmYellow = Color(0xFFF9C589);
  static const Color greyAccent = Color(0xFFB09B88);
  static const Color baseBackground = Color(0xFFFDF6F0);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static final Color crossedOutGreen = headingGreen.withValues(alpha: 0.5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.light(
        primary: headingGreen,
        secondary: warmYellow,
        tertiary: greyAccent,
        surface: baseBackground,
        onPrimary: cardWhite,
        onSurface: bodyTextGreen,
      ),
      scaffoldBackgroundColor: baseBackground,

      textTheme: TextTheme(
        headlineLarge: GoogleFonts.fraunces(
          color: headingGreen,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: GoogleFonts.fraunces(
          color: headingGreen,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.fraunces(
          color: headingGreen,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.fraunces(
          color: headingGreen,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        titleSmall: GoogleFonts.fraunces(
          color: headingGreen,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.commissioner(color: bodyTextGreen, fontSize: 16),
        bodyMedium: GoogleFonts.commissioner(
          color: bodyTextGreen,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.commissioner(
          color: greyAccent,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelLarge: GoogleFonts.commissioner(color: greyAccent, fontSize: 14),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        hintStyle: GoogleFonts.commissioner(color: greyAccent, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: greyAccent,
          textStyle: GoogleFonts.commissioner(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
