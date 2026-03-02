import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ui/theme/banking_color_extension.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/tokens/typography.dart';

/// Provides the light and dark [ThemeData] for the banking application.
///
/// Uses Material 3 and incorporates the banking design tokens.
abstract final class BankingTheme {
  // ---------------------------------------------------------------------------
  // Light
  // ---------------------------------------------------------------------------

  /// Light theme.
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: BankingColors.primary,
      primaryContainer: BankingColors.primaryLight,
      onPrimaryContainer: Colors.white,
      secondary: BankingColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: BankingColors.secondaryLight.withValues(alpha: 0.2),
      onSecondaryContainer: BankingColors.secondaryDark,
      tertiary: BankingColors.accent,
      onTertiary: Colors.white,
      error: BankingColors.error,
      onSurface: BankingColors.onBackgroundLight,
      surfaceContainerHighest: BankingColors.surfaceVariantLight,
      onSurfaceVariant: BankingColors.onBackgroundLightSecondary,
      outline: BankingColors.dividerLight,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: BankingColors.backgroundLight,
      dividerColor: BankingColors.dividerLight,
      bankingColorExtension: BankingColorExtension.light,
    );
  }

  // ---------------------------------------------------------------------------
  // Dark
  // ---------------------------------------------------------------------------

  /// Dark theme.
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: BankingColors.primaryLight,
      onPrimary: Colors.white,
      primaryContainer: BankingColors.primary,
      onPrimaryContainer: Colors.white,
      secondary: BankingColors.secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: BankingColors.secondaryDark.withValues(alpha: 0.3),
      onSecondaryContainer: BankingColors.secondaryLight,
      tertiary: BankingColors.accentLight,
      onTertiary: Colors.white,
      error: BankingColors.errorLight,
      onError: Colors.white,
      surface: BankingColors.surfaceDark,
      onSurface: BankingColors.onBackgroundDark,
      surfaceContainerHighest: BankingColors.surfaceVariantDark,
      onSurfaceVariant: BankingColors.onBackgroundDarkSecondary,
      outline: BankingColors.dividerDark,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BankingColors.backgroundDark,
      dividerColor: BankingColors.dividerDark,
      bankingColorExtension: BankingColorExtension.dark,
    );
  }

  // ---------------------------------------------------------------------------
  // Builder
  // ---------------------------------------------------------------------------

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color dividerColor,
    required BankingColorExtension bankingColorExtension,
  }) {
    final isLight = brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      dividerColor: dividerColor,

      // -- AppBar --
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.light : Brightness.dark,
          statusBarBrightness: isLight ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: BankingTypography.titleMedium.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),

      // -- Card --
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // -- Elevated Button --
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: BankingTypography.labelLarge,
          elevation: 0,
        ),
      ),

      // -- Outlined Button --
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.primary),
          textStyle: BankingTypography.labelLarge,
        ),
      ),

      // -- Text Button --
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: BankingTypography.labelLarge,
        ),
      ),

      // -- Input Decoration --
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? BankingColors.surfaceVariantLight
            : BankingColors.surfaceVariantDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        labelStyle: BankingTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: BankingTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),

      // -- Bottom Navigation --
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // -- Divider --
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      // -- Extensions --
      extensions: [bankingColorExtension],
    );
  }
}
