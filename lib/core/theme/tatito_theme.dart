import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tatito_colors.dart';

class TatitoTheme {
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TatitoColors.surfaceAlt,
      primaryColor: TatitoColors.brandGreen,
      colorScheme: ColorScheme.light(
        primary: TatitoColors.brandGreen,
        secondary: TatitoColors.brandGold,
        surface: TatitoColors.surface,
        error: TatitoColors.dangerRed,
        onPrimary: Colors.white,
        onSurface: TatitoColors.brandBlack,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: TatitoColors.surface,
        foregroundColor: TatitoColors.brandBlack,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: TatitoColors.brandGreenDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: TatitoColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: TatitoColors.borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TatitoColors.brandGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TatitoColors.brandGreen,
          side: const BorderSide(color: TatitoColors.brandGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TatitoColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TatitoColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TatitoColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TatitoColors.brandGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TatitoColors.dangerRed),
        ),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: TatitoColors.brandBlack,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: TatitoColors.brandBlack,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: TatitoColors.brandBlack,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: TatitoColors.brandBlack,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          color: TatitoColors.textBody,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: TatitoColors.textBody,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          color: TatitoColors.textMuted,
        ),
      ),
    );
  }
}
