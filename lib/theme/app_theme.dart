import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Budget Buddy color palette
class AppColors {
  static const Color primaryGreen = Color(0xFF23845C);
  static const Color darkGreen = Color(0xFF155C40);
  static const Color lightGreen = Color(0xFFE1F2E6);
  static const Color background = Color(0xFFF5F8F4);
  static const Color textDark = Color(0xFF26382F);
  static const Color textGray = Color(0xFF89958D);
  static const Color border = Color(0xFFDCE5DD);

  static const Color white = Colors.white;
  static const Color mutedText = textGray;
}

// Main application theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        surface: AppColors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
    );
  }
}
