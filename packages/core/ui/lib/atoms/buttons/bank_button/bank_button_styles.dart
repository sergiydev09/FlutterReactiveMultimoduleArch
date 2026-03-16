part of 'bank_button.dart';

abstract final class _BankButtonStyles {
  // ── Shape ──────────────────────────────────────────────────────────────────

  static final BorderRadius _borderRadius = BankingRadii.borderRadiusFull;

  // ── Size helpers ───────────────────────────────────────────────────────────

  static Size _minimumSizeFor(BankButtonSize size) => switch (size) {
    BankButtonSize.small => const Size(0, 36),
    BankButtonSize.medium => const Size(0, 48),
    BankButtonSize.large => const Size(0, 56),
  };

  static EdgeInsetsGeometry paddingFor(BankButtonSize size) => switch (size) {
    BankButtonSize.small =>
      const EdgeInsets.symmetric(horizontal: BankingSpacing.sm),
    BankButtonSize.medium =>
      const EdgeInsets.symmetric(horizontal: BankingSpacing.md),
    BankButtonSize.large =>
      const EdgeInsets.symmetric(horizontal: BankingSpacing.lg),
  };

  static double iconSizeFor(BankButtonSize size) => switch (size) {
    BankButtonSize.small => 16,
    BankButtonSize.medium => 20,
    BankButtonSize.large => 24,
  };

  // ── Variant styles ─────────────────────────────────────────────────────────

  static ButtonStyle solidStyle(BankButtonSize size) =>
      ElevatedButton.styleFrom(
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: BankingColors.surfaceVariantLight,
        disabledForegroundColor: BankingColors.onBackgroundLightSecondary,
        minimumSize: _minimumSizeFor(size),
        padding: paddingFor(size),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: BankingTypography.labelLarge,
      );

  static ButtonStyle outlinedStyle(BankButtonSize size) =>
      OutlinedButton.styleFrom(
        foregroundColor: BankingColors.primary,
        disabledForegroundColor: BankingColors.onBackgroundLightSecondary,
        minimumSize: _minimumSizeFor(size),
        padding: paddingFor(size),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        textStyle: BankingTypography.labelLarge,
      ).copyWith(
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: BankingColors.dividerLight);
          }
          return const BorderSide(color: BankingColors.primary);
        }),
      );

  static ButtonStyle subtleStyle(BankButtonSize size) =>
      ElevatedButton.styleFrom(
        backgroundColor: BankingColors.surfaceVariantLight,
        foregroundColor: BankingColors.primary,
        disabledBackgroundColor: BankingColors.surfaceVariantLight,
        disabledForegroundColor: BankingColors.onBackgroundLightSecondary,
        minimumSize: _minimumSizeFor(size),
        padding: paddingFor(size),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: BankingTypography.labelLarge,
      );

  static ButtonStyle ghostStyle(BankButtonSize size) =>
      TextButton.styleFrom(
        foregroundColor: BankingColors.primary,
        disabledForegroundColor: BankingColors.onBackgroundLightSecondary,
        minimumSize: _minimumSizeFor(size),
        padding: paddingFor(size),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        textStyle: BankingTypography.labelLarge,
      );

  static ButtonStyle iconStyle(BankButtonSize size) {
    final dimension = switch (size) {
      BankButtonSize.small => 36.0,
      BankButtonSize.medium => 48.0,
      BankButtonSize.large => 56.0,
    };
    return TextButton.styleFrom(
      foregroundColor: BankingColors.primary,
      disabledForegroundColor: BankingColors.onBackgroundLightSecondary,
      minimumSize: Size(dimension, dimension),
      maximumSize: Size(dimension, dimension),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: _borderRadius),
    );
  }

  static ButtonStyle nestedIconStyle(BankButtonSize size) =>
      ElevatedButton.styleFrom(
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: BankingColors.surfaceVariantLight,
        disabledForegroundColor: BankingColors.onBackgroundLightSecondary,
        minimumSize: _minimumSizeFor(size),
        padding: paddingFor(size),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: BankingTypography.labelLarge,
      );
}
