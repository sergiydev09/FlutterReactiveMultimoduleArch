import 'package:flutter/material.dart';

import 'package:ui/tokens/colors.dart';

/// A [ThemeExtension] that provides custom banking-specific colors
/// not covered by the standard Material [ColorScheme].
class BankingColorExtension extends ThemeExtension<BankingColorExtension> {
  const BankingColorExtension({
    required this.amountPositive,
    required this.amountNegative,
    required this.cardGradientStart,
    required this.cardGradientEnd,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  /// Light theme instance.
  static const light = BankingColorExtension(
    amountPositive: BankingColors.amountPositive,
    amountNegative: BankingColors.amountNegative,
    cardGradientStart: BankingColors.primary,
    cardGradientEnd: BankingColors.primaryLight,
    shimmerBase: Color(0xFFE0E3E8),
    shimmerHighlight: Color(0xFFF5F7FA),
  );

  /// Dark theme instance.
  static const dark = BankingColorExtension(
    amountPositive: Color(0xFF66BB6A),
    amountNegative: Color(0xFFEF5350),
    cardGradientStart: Color(0xFF1C2128),
    cardGradientEnd: Color(0xFF2D333B),
    shimmerBase: Color(0xFF2D333B),
    shimmerHighlight: Color(0xFF3D444D),
  );

  /// Color for positive amounts (income).
  final Color amountPositive;

  /// Color for negative amounts (expense).
  final Color amountNegative;

  /// Start color for bank card gradient.
  final Color cardGradientStart;

  /// End color for bank card gradient.
  final Color cardGradientEnd;

  /// Base color for shimmer loading animation.
  final Color shimmerBase;

  /// Highlight color for shimmer loading animation.
  final Color shimmerHighlight;

  @override
  ThemeExtension<BankingColorExtension> copyWith({
    Color? amountPositive,
    Color? amountNegative,
    Color? cardGradientStart,
    Color? cardGradientEnd,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return BankingColorExtension(
      amountPositive: amountPositive ?? this.amountPositive,
      amountNegative: amountNegative ?? this.amountNegative,
      cardGradientStart: cardGradientStart ?? this.cardGradientStart,
      cardGradientEnd: cardGradientEnd ?? this.cardGradientEnd,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  ThemeExtension<BankingColorExtension> lerp(
    covariant ThemeExtension<BankingColorExtension>? other,
    double t,
  ) {
    if (other is! BankingColorExtension) return this;
    return BankingColorExtension(
      amountPositive: Color.lerp(amountPositive, other.amountPositive, t)!,
      amountNegative: Color.lerp(amountNegative, other.amountNegative, t)!,
      cardGradientStart: Color.lerp(
        cardGradientStart,
        other.cardGradientStart,
        t,
      )!,
      cardGradientEnd: Color.lerp(cardGradientEnd, other.cardGradientEnd, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
    );
  }
}

/// Convenience extension to access [BankingColorExtension] from [BuildContext].
extension BankingColorExtensionAccess on BuildContext {
  /// Retrieves the [BankingColorExtension] from the current theme.
  BankingColorExtension get bankingColors =>
      Theme.of(this).extension<BankingColorExtension>()!;
}
