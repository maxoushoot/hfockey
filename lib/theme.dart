import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Couleurs principales - Bleu et Blanc
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color lightBlue = Color(0xFF60A5FA);
  static const Color deepBlue = Color(0xFF1E40AF);
  static const Color accentBlue = Color(0xFF3B82F6);
  
  // Couleurs neutres
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF64748B);
  static const Color darkGray = Color(0xFF334155);
  static const Color black = Color(0xFF0F172A);
  
  // Couleurs de statut
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF06B6D4);
  
  // Couleurs de hockey
  static const Color ice = Color(0xFFFFFFFF);
  static const Color puck = Color(0xFF1F2937);
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    brightness: Brightness.light,
    primary: AppColors.primaryBlue,
    onPrimary: AppColors.white,
    secondary: AppColors.accentBlue,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.black,
    background: AppColors.white,
    onBackground: AppColors.black,
    error: AppColors.error,
    onError: AppColors.white,
  ),
  
  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.black,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: AppColors.gray.withValues(alpha: 0.1),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
  ),
  
  // Cards
  cardTheme: CardThemeData(
    color: AppColors.white,
    elevation: 2,
    shadowColor: AppColors.primaryBlue.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppColors.lightBlue.withValues(alpha: 0.1),
        width: 1,
      ),
    ),
  ),
  
  // Buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: AppColors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      side: const BorderSide(color: AppColors.primaryBlue),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ),
  
  // Input fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: AppColors.lightBlue.withValues(alpha: 0.3),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: GoogleFonts.inter(
      color: AppColors.gray,
      fontSize: 14,
    ),
    hintStyle: GoogleFonts.inter(
      color: AppColors.gray,
      fontSize: 14,
    ),
  ),
  
  // Bottom Navigation
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.white,
    selectedItemColor: AppColors.primaryBlue,
    unselectedItemColor: AppColors.gray,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  
  // Typography
  textTheme: GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.black,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.black,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.gray,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.gray,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.gray,
    ),
  ),
  
  // Dividers
  dividerTheme: DividerThemeData(
    color: AppColors.lightBlue.withValues(alpha: 0.2),
    thickness: 1,
  ),
  
  // Chips
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.white,
    selectedColor: AppColors.primaryBlue,
    labelStyle: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.accentBlue,
    onPrimary: AppColors.black,
    secondary: AppColors.lightBlue,
    onSecondary: AppColors.black,
    surface: Color(0xFF1E293B),
    onSurface: AppColors.white,
    background: AppColors.black,
    onBackground: AppColors.white,
    error: AppColors.error,
    onError: AppColors.white,
  ),
  
  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFF1E293B),
    foregroundColor: AppColors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: AppColors.black.withValues(alpha: 0.3),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
  ),
  
  // Cards
  cardTheme: CardThemeData(
    color: const Color(0xFF1E293B),
    elevation: 2,
    shadowColor: AppColors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  
  // Bottom Navigation
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E293B),
    selectedItemColor: AppColors.accentBlue,
    unselectedItemColor: AppColors.gray,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  
  // Typography (same as light but with white colors)
  textTheme: GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.white,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.white,
    ),
    // ... autres styles avec couleurs ajustées pour le mode sombre
  ),
);