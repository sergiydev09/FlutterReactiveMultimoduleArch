import 'package:equatable/equatable.dart';

/// Value object representing a monetary amount with its currency.
class Money extends Equatable {
  const Money({
    required this.amount,
    this.currency = 'EUR',
  });

  /// Creates a zero-value Money in the given [currency].
  const Money.zero({this.currency = 'EUR'}) : amount = 0;

  /// The numeric amount.
  final double amount;

  /// ISO 4217 currency code.
  final String currency;

  /// Whether the amount is positive.
  bool get isPositive => amount >= 0;

  /// Whether the amount is negative.
  bool get isNegative => amount < 0;

  /// Returns a formatted display string (e.g. "1.234,56 EUR").
  String get formatted {
    final absolute = amount.abs();
    final parts = absolute.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(integerPart[i]);
    }

    final sign = isNegative ? '-' : '';
    return '$sign$buffer,$decimalPart $currency';
  }

  /// Returns a signed formatted string (e.g. "+1.234,56 EUR").
  String get signedFormatted {
    final prefix = isPositive ? '+' : '';
    return '$prefix$formatted';
  }

  /// Adds two Money values. Both must share the same currency.
  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(amount: amount + other.amount, currency: currency);
  }

  /// Subtracts two Money values. Both must share the same currency.
  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(amount: amount - other.amount, currency: currency);
  }

  /// Negates the amount.
  Money operator -() => Money(amount: -amount, currency: currency);

  /// Creates a copy with optionally overridden fields.
  Money copyWith({double? amount, String? currency}) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [amount, currency];
}
