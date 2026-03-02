/// Utility class for formatting currency, dates, and IBANs.
class Formatters {
  const Formatters._();

  // ---------------------------------------------------------------------------
  // Currency
  // ---------------------------------------------------------------------------

  /// Formats [amount] as a currency string.
  ///
  /// Examples:
  /// ```dart
  /// formatCurrency(1234.56, 'EUR') // '1.234,56 EUR'
  /// formatCurrency(-50.00, 'USD')  // '-50,00 USD'
  /// ```
  static String formatCurrency(
    double amount, {
    String currency = 'EUR',
    String thousandSeparator = '.',
    String decimalSeparator = ',',
    int decimalDigits = 2,
  }) {
    final isNegative = amount < 0;
    final absolute = amount.abs();

    final parts = absolute.toStringAsFixed(decimalDigits).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators.
    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(thousandSeparator);
      }
      buffer.write(integerPart[i]);
    }

    final formatted = '$buffer$decimalSeparator$decimalPart $currency';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Formats [amount] with a sign prefix.
  ///
  /// Positive values get a '+' prefix, negative values get a '-' prefix.
  static String formatSignedCurrency(
    double amount, {
    String currency = 'EUR',
  }) {
    final prefix = amount >= 0 ? '+' : '';
    return '$prefix${formatCurrency(amount, currency: currency)}';
  }

  // ---------------------------------------------------------------------------
  // Date
  // ---------------------------------------------------------------------------

  /// Formats a [DateTime] as `dd/MM/yyyy`.
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  /// Formats a [DateTime] as `dd/MM/yyyy HH:mm`.
  static String formatDateTime(DateTime date) {
    final datePart = formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$datePart $hour:$minute';
  }

  /// Returns a relative time string (e.g. "Just now", "5 min ago", "Yesterday").
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return formatDate(date);
  }

  // ---------------------------------------------------------------------------
  // IBAN
  // ---------------------------------------------------------------------------

  /// Formats an IBAN string into groups of 4 characters.
  ///
  /// Example: `ES1234567890123456` -> `ES12 3456 7890 1234 56`
  static String formatIban(String iban) {
    final clean = iban.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final buffer = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  /// Masks an IBAN showing only the last 4 characters.
  ///
  /// Example: `ES1234567890123456` -> `**** **** **** 3456`
  static String maskIban(String iban) {
    final clean = iban.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (clean.length <= 4) return clean;
    final lastFour = clean.substring(clean.length - 4);
    final maskedLength = clean.length - 4;
    final masked = List.filled(maskedLength, '*').join();
    return formatIban('$masked$lastFour');
  }
}
