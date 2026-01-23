import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Fixit Design System - Theme Configuration
/// Complete theme configuration based on the Fixit Style Guide v1.0
/// Includes both Light and Dark themes
class AppTheme {
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,

        secondary: AppColors.textSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.slate100,
        onSecondaryContainer: AppColors.textPrimary,

        tertiary: AppColors.info,
        onTertiary: Colors.white,

        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: AppColors.statusFailedBg,
        onErrorContainer: AppColors.statusFailedText,

        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.slate50,

        outline: AppColors.borderDefault,
        outlineVariant: AppColors.borderLight,

        shadow: AppColors.shadow,
        scrim: AppColors.overlayDark,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headline2.copyWith(
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
        surfaceTintColor: Colors.transparent,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.headline1.copyWith(
          color: AppColors.textPrimary,
        ),
        displayMedium: AppTypography.headline2.copyWith(
          color: AppColors.textPrimary,
        ),
        displaySmall: AppTypography.headline3.copyWith(
          color: AppColors.textPrimary,
        ),

        headlineLarge: AppTypography.headline1.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineMedium: AppTypography.headline2.copyWith(
          color: AppColors.textPrimary,
        ),
        headlineSmall: AppTypography.headline3.copyWith(
          color: AppColors.textPrimary,
        ),

        titleLarge: AppTypography.subtitle1.copyWith(
          color: AppColors.textPrimary,
        ),
        titleMedium: AppTypography.subtitle2.copyWith(
          color: AppColors.textPrimary,
        ),
        titleSmall: AppTypography.label.copyWith(color: AppColors.textPrimary),

        bodyLarge: AppTypography.bodyText.copyWith(
          color: AppColors.textSecondary,
        ),
        bodyMedium: AppTypography.bodyTextSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
        ),

        labelLarge: AppTypography.button.copyWith(color: AppColors.textPrimary),
        labelMedium: AppTypography.buttonSmall.copyWith(
          color: AppColors.textPrimary,
        ),
        labelSmall: AppTypography.captionSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: AppColors.primary, size: 24),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimaryBg,
          foregroundColor: AppColors.buttonPrimaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(88, 48),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderDefault, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(88, 48),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.button,
        ),
      ),

      // Filled Button Theme (Secondary Button)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.buttonSecondaryBg,
          foregroundColor: AppColors.buttonSecondaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(88, 48),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorderFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),

        // Text styles
        labelStyle: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelStyle: AppTypography.label.copyWith(
          color: AppColors.primary,
        ),
        hintStyle: AppTypography.inputText.copyWith(
          color: AppColors.textDisabled,
        ),
        errorStyle: AppTypography.captionSmall.copyWith(
          color: AppColors.danger,
        ),

        // Icon theme
        iconColor: AppColors.textSecondary,
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.slate100,
        deleteIconColor: AppColors.textSecondary,
        disabledColor: AppColors.slate50,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTypography.badge.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle: AppTypography.badge.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: BorderSide.none,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: AppTypography.captionSmall.copyWith(
          fontWeight: AppTypography.semiBold,
        ),
        unselectedLabelStyle: AppTypography.captionSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTypography.headline3.copyWith(
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppTypography.bodyText.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate800,
        contentTextStyle: AppTypography.bodyTextSmall.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.slate200,
        circularTrackColor: AppColors.slate200,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.slate300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.slate200;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.borderDefault, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderDefault;
        }),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTypography.subtitle2.copyWith(
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: AppTypography.caption.copyWith(
          color: AppColors.textTertiary,
        ),
        leadingAndTrailingTextStyle: AppTypography.bodyTextSmall.copyWith(
          color: AppColors.textSecondary,
        ),
        iconColor: AppColors.primary,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Badge Theme
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.danger,
        textColor: Colors.white,
        smallSize: 6,
        largeSize: 16,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDarkTheme,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryDarkTheme,
        onPrimaryContainer: Colors.white,

        secondary: AppColors.textSecondaryDark,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.surfaceDarkTheme,
        onSecondaryContainer: AppColors.textPrimaryDark,

        tertiary: AppColors.primaryDarkTheme,
        onTertiary: Colors.white,

        error: AppColors.dangerDarkTheme,
        onError: Colors.white,
        errorContainer: AppColors.statusFailedBgDark,
        onErrorContainer: AppColors.statusFailedTextDark,

        surface: AppColors.surfaceDarkTheme,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.backgroundDarkTheme,

        outline: AppColors.borderDefaultDark,
        outlineVariant: AppColors.borderLightDark,

        shadow: Colors.black,
        scrim: AppColors.scrimDark,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.backgroundDarkTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDarkTheme,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headline2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primaryDarkTheme,
          size: 24,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.headline1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTypography.headline2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: AppTypography.headline3.copyWith(
          color: AppColors.textPrimaryDark,
        ),

        headlineLarge: AppTypography.headline1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineMedium: AppTypography.headline2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        headlineSmall: AppTypography.headline3.copyWith(
          color: AppColors.textPrimaryDark,
        ),

        titleLarge: AppTypography.subtitle1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleMedium: AppTypography.subtitle2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        titleSmall: AppTypography.label.copyWith(
          color: AppColors.textPrimaryDark,
        ),

        bodyLarge: AppTypography.bodyText.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTypography.bodyTextSmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        bodySmall: AppTypography.caption.copyWith(
          color: AppColors.textTertiaryDark,
        ),

        labelLarge: AppTypography.button.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: AppTypography.buttonSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelSmall: AppTypography.captionSmall.copyWith(
          color: AppColors.textTertiaryDark,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryDarkTheme,
        size: 24,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surfaceDarkTheme,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderLightDark, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimaryBgDark,
          foregroundColor: AppColors.buttonPrimaryTextDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(88, 56),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.buttonSecondaryTextDark,
          backgroundColor: AppColors.buttonSecondaryBgDark,
          side: const BorderSide(
            color: AppColors.buttonSecondaryBorderDark,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(88, 56),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDarkTheme,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.button,
        ),
      ),

      // Filled Button Theme (Secondary Button)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.buttonSecondaryBgDark,
          foregroundColor: AppColors.buttonSecondaryTextDark,
          elevation: 0,
          side: const BorderSide(
            color: AppColors.buttonSecondaryBorderDark,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTypography.button,
          minimumSize: const Size(88, 56),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackgroundDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        // Border styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorderDark,
            width: 0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorderDark,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorderFocusedDark,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.dangerDarkTheme,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.dangerDarkTheme,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.borderLightDark,
            width: 1,
          ),
        ),

        // Text styles
        labelStyle: AppTypography.label.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        floatingLabelStyle: AppTypography.label.copyWith(
          color: AppColors.primaryDarkTheme,
        ),
        hintStyle: AppTypography.inputText.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        errorStyle: AppTypography.captionSmall.copyWith(
          color: AppColors.dangerDarkTheme,
        ),

        // Icon theme
        iconColor: AppColors.textSecondaryDark,
        prefixIconColor: AppColors.textSecondaryDark,
        suffixIconColor: AppColors.primaryDarkTheme,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceDarkTheme,
        deleteIconColor: AppColors.textSecondaryDark,
        disabledColor: AppColors.backgroundDarkTheme,
        selectedColor: AppColors.primaryDarkTheme,
        secondarySelectedColor: AppColors.primaryDarkTheme,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTypography.badge.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        secondaryLabelStyle: AppTypography.badge.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        side: const BorderSide(color: AppColors.borderLightDark, width: 1),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDarkTheme,
        selectedItemColor: AppColors.primaryDarkTheme,
        unselectedItemColor: AppColors.textTertiaryDark,
        selectedLabelStyle: AppTypography.captionSmall.copyWith(
          fontWeight: AppTypography.semiBold,
        ),
        unselectedLabelStyle: AppTypography.captionSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDarkTheme,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTypography.headline3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyText.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceDarkTheme,
        contentTextStyle: AppTypography.bodyTextSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDarkTheme,
        linearTrackColor: AppColors.borderLightDark,
        circularTrackColor: AppColors.borderLightDark,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTheme;
          }
          return AppColors.borderDefaultDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTheme.withValues(alpha: 0.5);
          }
          return AppColors.borderLightDark;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTheme;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.borderDefaultDark, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTheme;
          }
          return AppColors.borderDefaultDark;
        }),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDarkTheme,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTypography.subtitle2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        subtitleTextStyle: AppTypography.caption.copyWith(
          color: AppColors.textTertiaryDark,
        ),
        leadingAndTrailingTextStyle: AppTypography.bodyTextSmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        iconColor: AppColors.primaryDarkTheme,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Badge Theme
      badgeTheme: const BadgeThemeData(
        backgroundColor: AppColors.dangerDarkTheme,
        textColor: Colors.white,
        smallSize: 6,
        largeSize: 16,
      ),
    );
  }
}
