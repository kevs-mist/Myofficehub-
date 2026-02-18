import 'package:flutter/material.dart';

class AppColors {
  // Synthesis Palette: Deep Royal Indigo (Serious) + Azure/Rose Highlights (Colorful)
  static const Color primary = Color(
    0xFF312E81,
  ); // Deep Royal Indigo (Serious & Clean)
  static const Color secondary = Color(0xFF6366F1); // Indigo (Energetic)
  static const Color accent = Color(
    0xFF0EA5E9,
  ); // Azure Blue (Professional Pop)
  static const Color highlight = Color(0xFFEC4899); // Rose (Fun Hint)

  static const Color background = Color(0xFFF8FAFC); // Clean Slate
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1E1B4B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0F172A);

  // Synthesis Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF312E81), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCardBackground = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Background Elements (Subtle Glows + Defined Shapes)
  static const Color blob1 = Color(0x1A6366F1);
  static const Color blob2 = Color(0x1A0EA5E9);
  static const Color glassSurface = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x2664748B);
}
