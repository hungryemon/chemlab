import 'package:flutter/material.dart';

/// Color schemes for ChemLab app following Material 3 design guidelines
class AppColors {
  // Light theme color scheme
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: Color(0xFF006A65),
    secondary: Color(0xFF4A6572),
    tertiary: Color(0xFF7C4DFF),
    surface: Color(0xFFFFFFFF),
    background: Color(0xFFF5F5F5),
    error: Color(0xFFB00020),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onTertiary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    onBackground: Color(0xFF000000),
    onError: Color(0xFFFFFFFF),
  );

  // Dark theme color scheme
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Color(0xFF4DB6AC),
    secondary: Color(0xFF81C784),
    tertiary: Color(0xFF9575CD),
    surface: Color(0xFF121212),
    background: Color(0xFF000000),
    error: Color(0xFFCF6679),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onTertiary: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    onBackground: Color(0xFFFFFFFF),
    onError: Color(0xFF000000),
  );

  // Additional semantic colors
  static const Color hazardWarning = Color(0xFFFFC107);
  static const Color safeCompound = Color(0xFF4CAF50);
  
  // Spacing constants
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;
  static const double paddingXLarge = 20.0;
  
  // Border radius constants
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}