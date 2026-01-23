import 'package:flutter/material.dart';

/// Fixit Design System - Typography
/// Font Family: Inter
class AppTypography {
  AppTypography._();

  // Font Family
  static const String fontFamily = 'Inter';

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Headline 1 - Large, bold headlines
  static const TextStyle headline1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.015,
  );

  // Headline 2 - Section headers
  static const TextStyle headline2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: bold,
    height: 1.27,
    letterSpacing: -0.015,
  );

  // Headline 3 - Subsection headers
  static const TextStyle headline3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.3,
  );

  // Subtitle 1 - Prominent subtitles
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.33,
  );

  // Subtitle 2 - Secondary subtitles
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.375,
  );

  // Body Text - Regular content
  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
  );

  // Body Text Small
  static const TextStyle bodyTextSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
  );

  // Caption - Small descriptive text
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.43,
  );

  // Caption Small - Very small text
  static const TextStyle captionSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.33,
  );

  // Overline - Small uppercase labels
  static const TextStyle overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: bold,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Button Text - Text for buttons
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.25,
  );

  // Button Text Small
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.29,
  );

  // Label - Form labels
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.43,
  );

  // Input Text - Text inside input fields
  static const TextStyle inputText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
  );

  // Badge Text - Text inside badges
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: bold,
    height: 1.33,
    letterSpacing: 0.5,
  );
}
