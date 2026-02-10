import 'package:flutter/material.dart';

/// App-wide color constants with pastel-dark hybrid theme
/// Designed for premium, calm, yet vibrant aesthetic
class AppColors {
  AppColors._();

  // Primary Colors - Soft Indigo/Violet
  static const Color primaryLight = Color(0xFF6366F1); // Indigo-500
  static const Color primaryMain = Color(0xFF8B5CF6); // Violet-500
  static const Color primaryDark = Color(0xFF7C3AED); // Violet-600

  // Accent Colors - Mint/Teal
  static const Color accentLight = Color(0xFF10B981); // Emerald-500
  static const Color accentMain = Color(0xFF14B8A6); // Teal-500
  static const Color accentDark = Color(0xFF0D9488); // Teal-600

  // Success & Status Colors
  static const Color success = Color(0xFF34D399); // Emerald-400
  static const Color warning = Color(0xFFFBBF24); // Amber-400
  static const Color error = Color(0xFFF87171); // Red-400
  static const Color info = Color(0xFF60A5FA); // Blue-400

  // Background Colors
  static const Color backgroundDark = Color(0xFF0F172A); // Slate-900
  static const Color backgroundMedium = Color(0xFF1E293B); // Slate-800
  static const Color backgroundLight = Color(0xFF334155); // Slate-700
  static const Color backgroundCard = Color(0xFF1E293B); // Slate-800

  // Surface Colors
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);

  // Text Colors
  static const Color textPrimary = Color(0xFFF1F5F9); // Slate-100
  static const Color textSecondary = Color(0xFFCBD5E1); // Slate-300
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color textDisabled = Color(0xFF64748B); // Slate-500

  // Glassmorphism
  static const Color glassBackground = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const double glassBlur = 10.0;

  // Voice Active Gradient
  static const List<Color> voiceGradient = [
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
  ];

  // Category Colors
  static const Color categoryFruits = Color(0xFFFF6B9D);
  static const Color categoryVegetables = Color(0xFF4ADE80);
  static const Color categoryDairy = Color(0xFF60A5FA);
  static const Color categoryMeat = Color(0xFFEF4444);
  static const Color categoryBakery = Color(0xFFFBBF24);
  static const Color categoryBeverages = Color(0xFF8B5CF6);
  static const Color categorySnacks = Color(0xFFF97316);
  static const Color categoryOther = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryMain],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentLight, accentMain],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient voiceActiveGradient = LinearGradient(
    colors: voiceGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Opacity values
  static const double opacityHigh = 0.87;
  static const double opacityMedium = 0.60;
  static const double opacityLow = 0.38;
  static const double opacityDisabled = 0.12;

  // Shadow colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.1);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.2);
  static Color shadowHeavy = Colors.black.withValues(alpha: 0.3);
}
