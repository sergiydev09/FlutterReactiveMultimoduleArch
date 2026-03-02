import 'package:equatable/equatable.dart';

/// Value object representing an International Bank Account Number.
class Iban extends Equatable {
  /// Creates an [Iban] from a raw string. Whitespace is stripped.
  const Iban(this._raw);

  final String _raw;

  /// The normalized (uppercase, no spaces) IBAN.
  String get value => _raw.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  /// The country code (first 2 characters).
  String get countryCode => value.length >= 2 ? value.substring(0, 2) : '';

  /// The check digits (characters 3-4).
  String get checkDigits => value.length >= 4 ? value.substring(2, 4) : '';

  /// Formatted IBAN in groups of 4 (e.g. "ES12 3456 7890 1234 56").
  String get formatted {
    final clean = value;
    final buffer = StringBuffer();
    for (var i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  /// Masked display showing only the last 4 digits.
  ///
  /// Example: "**** **** **** 3456"
  String get masked {
    final clean = value;
    if (clean.length <= 4) return clean;
    final lastFour = clean.substring(clean.length - 4);
    final maskedLength = clean.length - 4;
    final stars = List.filled(maskedLength, '*').join();
    // Format with spaces every 4 characters.
    final full = '$stars$lastFour';
    final buffer = StringBuffer();
    for (var i = 0; i < full.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(full[i]);
    }
    return buffer.toString();
  }

  /// Basic structural validation.
  ///
  /// Checks length (15-34 characters) and that the first two characters
  /// are letters followed by two digits.
  bool get isValid {
    final clean = value;
    if (clean.length < 15 || clean.length > 34) return false;
    final pattern = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$');
    return pattern.hasMatch(clean);
  }

  @override
  String toString() => formatted;

  @override
  List<Object?> get props => [value];
}
