import 'package:flutter/material.dart';

/// Fixit Design System - Color Palette
/// Based on the Fixit Light Style Guide v1.0 and Dark Style Guide v1.0
class AppColors {
  AppColors._();

  // Brand & Primary Colors
  // Light theme primary
  static const Color primary = Color(0xFF2196F3); // Brand Blue (Light)
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Dark theme primary
  static const Color primaryDarkTheme = Color(0xFF137FEC); // Brand Blue (Dark)

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50); // Success Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  static const Color warning = Color(0xFFFFB300); // Warning Amber
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color warningDark = Color(0xFFFFA000);

  static const Color danger = Color(0xFFF44336); // Danger Red
  static const Color dangerLight = Color(0xFFE57373);
  static const Color dangerDark = Color(0xFFD32F2F);

  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);

  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF5F7F8);
  static const Color backgroundDark = Color(0xFF101A22);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF0D151C);
  static const Color textSecondary = Color(0xFF49779C);
  static const Color textTertiary = Color(0xFF64748B); // slate-500
  static const Color textDisabled = Color(0xFF94A3B8); // slate-400

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0); // slate-200
  static const Color borderDefault = Color(0xFFCBD5E1); // slate-300
  static const Color borderDark = Color(0xFF94A3B8); // slate-400

  // Divider Colors
  static const Color divider = Color(0xFFF1F5F9); // slate-100

  // Status Badge Colors
  static const Color statusCompletedBg = Color(0xFFDCFCE7); // green-100
  static const Color statusCompletedText = Color(0xFF15803D); // green-700

  static const Color statusPendingBg = Color(0xFFFEF3C7); // amber-100
  static const Color statusPendingText = Color(0xFFA16207); // amber-700

  static const Color statusInProgressBg = Color(0xFFDBEAFE); // blue-100
  static const Color statusInProgressText = Color(0xFF1D4ED8); // blue-700

  static const Color statusFailedBg = Color(0xFFFEE2E2); // red-100
  static const Color statusFailedText = Color(0xFFB91C1C); // red-700

  // Overlay Colors
  static const Color overlay = Color(0x1A000000); // 10% black
  static const Color overlayDark = Color(0x33000000); // 20% black

  // Shadow Colors
  static const Color shadow = Color(0x0D000000); // 5% black
  static const Color shadowMedium = Color(0x1A000000); // 10% black
  static const Color shadowStrong = Color(0x33000000); // 20% black

  // Input Field Colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE2E8F0); // slate-200
  static const Color inputBorderFocused = primary;
  static const Color inputText = Color(0xFF0F172A); // slate-900

  // Button Colors
  static const Color buttonPrimaryBg = primary;
  static const Color buttonPrimaryText = Color(0xFFFFFFFF);
  static const Color buttonSecondaryBg = Color(0xFFF1F5F9); // slate-100
  static const Color buttonSecondaryText = Color(0xFF0D151C);

  // Slate Palette (for additional flexibility)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ============================================
  // DARK THEME COLORS
  // ============================================

  // Dark Theme Semantic Colors (updated for dark mode)
  static const Color successDarkTheme = Color(
    0xFF22C55E,
  ); // Success Green (Dark)
  static const Color warningDarkTheme = Color(
    0xFFF59E0B,
  ); // Warning Amber (Dark)
  static const Color dangerDarkTheme = Color(0xFFEF4444); // Danger Red (Dark)

  // Dark Theme Backgrounds
  static const Color backgroundDarkTheme = Color(
    0xFF101922,
  ); // Main dark background
  static const Color surfaceDarkTheme = Color(
    0xFF1C1C1E,
  ); // Card/surface background

  // Dark Theme Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryDark = Color(0xFF92ADC9); // Muted blue-gray
  static const Color textTertiaryDark = Color(0xFF556B82); // Placeholder text
  static const Color textDisabledDark = Color(0xFF3D4F5F); // Disabled text

  // Dark Theme Border Colors
  static const Color borderLightDark = Color(0xFF324D67); // Subtle borders
  static const Color borderDefaultDark = Color(0xFF2A3F54); // Default borders
  static const Color dividerDark = Color(0x0DFFFFFF); // White with 5% opacity

  // Dark Theme Status Badge Colors
  static const Color statusInProgressBgDark = Color(
    0x33137FEC,
  ); // Primary with 20% opacity
  static const Color statusInProgressTextDark = Color(0xFF137FEC);
  static const Color statusInProgressBorderDark = Color(
    0x4D137FEC,
  ); // Primary with 30% opacity

  static const Color statusCompletedBgDark = Color(
    0x3322C55E,
  ); // Green with 20% opacity
  static const Color statusCompletedTextDark = Color(0xFF22C55E);
  static const Color statusCompletedBorderDark = Color(
    0x4D22C55E,
  ); // Green with 30% opacity

  static const Color statusFailedBgDark = Color(
    0x33EF4444,
  ); // Red with 20% opacity
  static const Color statusFailedTextDark = Color(0xFFEF4444);
  static const Color statusFailedBorderDark = Color(
    0x4DEF4444,
  ); // Red with 30% opacity

  static const Color statusPendingBgDark = Color(
    0x33F59E0B,
  ); // Amber with 20% opacity
  static const Color statusPendingTextDark = Color(0xFFF59E0B);
  static const Color statusPendingBorderDark = Color(
    0x4DF59E0B,
  ); // Amber with 30% opacity

  // Dark Theme Input Colors
  static const Color inputBackgroundDark = Color(0xFF1C1C1E);
  static const Color inputBorderDark = Color(0x00000000); // Transparent
  static const Color inputBorderFocusedDark = primaryDarkTheme;
  static const Color inputTextDark = Color(0xFFFFFFFF);

  // Dark Theme Button Colors
  static const Color buttonPrimaryBgDark = primaryDarkTheme;
  static const Color buttonPrimaryTextDark = Color(0xFFFFFFFF);
  static const Color buttonSecondaryBgDark = Color(0x00000000); // Transparent
  static const Color buttonSecondaryBorderDark = Color(0xFF324D67);
  static const Color buttonSecondaryTextDark = Color(0xFFFFFFFF);

  // Dark Theme Overlay Colors
  static const Color overlayDarkTheme = Color(0x1AFFFFFF); // 10% white
  static const Color scrimDark = Color(0x80000000); // 50% black
}
