import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/money.freezed.dart';

/// Value object representing a monetary amount with its currency.
@freezed
abstract class Money with _$Money {
  const factory Money({
    required double amount,
    @Default('EUR') String currency,
  }) = _Money;

  const Money._();

  /// Creates a zero-value Money in the given [currency].
  static const zero = Money(amount: 0);

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
}
