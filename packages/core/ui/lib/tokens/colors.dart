import 'package:flutter/material.dart';

/// Design tokens for colors used throughout the banking application.
///
/// Provides both light and dark palette variants to support theming.
abstract final class BankingColors {
  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  /// Primary deep blue - trust, stability.
  static const Color primary = Color(0xFF1A3A5C);

  /// Darker shade of primary for pressed / active states.
  static const Color primaryDark = Color(0xFF0F2640);

  /// Lighter shade of primary.
  static const Color primaryLight = Color(0xFF2C5F8A);

  /// Secondary green - growth, positive actions.
  static const Color secondary = Color(0xFF2E7D32);

  /// Darker shade of secondary.
  static const Color secondaryDark = Color(0xFF1B5E20);

  /// Lighter shade of secondary.
  static const Color secondaryLight = Color(0xFF4CAF50);

  /// Accent amber - highlights, warnings, CTAs.
  static const Color accent = Color(0xFFFF6F00);

  /// Lighter accent.
  static const Color accentLight = Color(0xFFFF9800);

  // ---------------------------------------------------------------------------
  // Semantic
  // ---------------------------------------------------------------------------

  /// Error / destructive actions.
  static const Color error = Color(0xFFD32F2F);

  /// Error on dark surfaces.
  static const Color errorLight = Color(0xFFEF5350);

  /// Success.
  static const Color success = Color(0xFF2E7D32);

  /// Warning.
  static const Color warning = Color(0xFFF9A825);

  /// Informational.
  static const Color info = Color(0xFF1976D2);

  // ---------------------------------------------------------------------------
  // Light theme surfaces
  // ---------------------------------------------------------------------------

  /// Light background.
  static const Color backgroundLight = Color(0xFFF5F7FA);

  /// Light surface (cards, sheets).
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Light surface variant.
  static const Color surfaceVariantLight = Color(0xFFEEF1F6);

  /// Primary text on light surfaces.
  static const Color onBackgroundLight = Color(0xFF1C1C1E);

  /// Secondary text on light surfaces.
  static const Color onBackgroundLightSecondary = Color(0xFF6B7280);

  /// Divider color for light theme.
  static const Color dividerLight = Color(0xFFE0E3E8);

  // ---------------------------------------------------------------------------
  // Dark theme surfaces
  // ---------------------------------------------------------------------------

  /// Dark background.
  static const Color backgroundDark = Color(0xFF0F1419);

  /// Dark surface (cards, sheets).
  static const Color surfaceDark = Color(0xFF1C2128);

  /// Dark surface variant.
  static const Color surfaceVariantDark = Color(0xFF2D333B);

  /// Primary text on dark surfaces.
  static const Color onBackgroundDark = Color(0xFFE6EDF3);

  /// Secondary text on dark surfaces.
  static const Color onBackgroundDarkSecondary = Color(0xFF8B949E);

  /// Divider color for dark theme.
  static const Color dividerDark = Color(0xFF30363D);

  // ---------------------------------------------------------------------------
  // Amount colors
  // ---------------------------------------------------------------------------

  /// Positive amount (income, credit).
  static const Color amountPositive = Color(0xFF2E7D32);

  /// Negative amount (expense, debit).
  static const Color amountNegative = Color(0xFFD32F2F);
}
