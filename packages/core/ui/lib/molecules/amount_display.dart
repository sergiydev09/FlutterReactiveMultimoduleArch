import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../theme/banking_color_extension.dart';
import '../tokens/typography.dart';
import '../utils/preview_wrapper.dart';

/// Displays a formatted currency amount with sign-aware coloring.
///
/// Positive amounts are shown in green, negative in red.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    required this.amount,
    super.key,
    this.currency = 'EUR',
    this.textStyle,
    this.showSign = true,
    this.compact = false,
  });

  /// The monetary amount to display.
  final double amount;

  /// The ISO 4217 currency code.
  final String currency;

  /// Optional override for the text style. Color will still be applied.
  final TextStyle? textStyle;

  /// Whether to show a + or - sign.
  final bool showSign;

  /// Whether to use a compact representation (e.g. for lists).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bankingColors = context.bankingColors;
    final isPositive = amount >= 0;

    final color = isPositive
        ? bankingColors.amountPositive
        : bankingColors.amountNegative;

    final style = (textStyle ?? BankingTypography.titleMedium).copyWith(
      color: color,
    );

    final formattedAmount = _format(amount.abs());
    final sign = showSign ? (isPositive ? '+' : '-') : (isPositive ? '' : '-');
    final text = compact
        ? '$sign$formattedAmount $currency'
        : '$sign $formattedAmount $currency';

    return Text(text, style: style);
  }

  /// Formats the absolute value with 2 decimal places and thousand separators.
  String _format(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    return '$buffer,$decimalPart';
  }

// --- Previews ---

  @Preview(
    name: 'Positive Amount',
    group: 'AmountDisplay',
    wrapper: appPreviewWrapper,
  )
  static Widget positivePreview() => const AmountDisplay(
        amount: 1450.50,
      );

  @Preview(
    name: 'Negative Amount',
    group: 'AmountDisplay',
    wrapper: appPreviewWrapper,
  )
  static Widget negativePreview() => const AmountDisplay(
        amount: -25.99,
      );

  @Preview(
    name: 'Compact Preview',
    group: 'AmountDisplay',
    wrapper: appPreviewWrapper,
  )
  static Widget compactPreview() => const AmountDisplay(
        amount: 50,
        compact: true,
      );

}
