import 'package:equatable/equatable.dart';

/// The type of bank account.
enum AccountType {
  /// Standard checking / current account.
  current,

  /// Savings account.
  savings,

  /// Investment account.
  investment,
}

/// Represents a bank account owned by the user.
class Account extends Equatable {
  const Account({
    required this.id,
    required this.type,
    required this.name,
    required this.iban,
    required this.balance,
    required this.currency,
    this.isMain = false,
  });

  /// Unique account identifier.
  final String id;

  /// Account type.
  final AccountType type;

  /// Display name of the account.
  final String name;

  /// International Bank Account Number.
  final String iban;

  /// Current balance.
  final double balance;

  /// ISO 4217 currency code (e.g. EUR, USD).
  final String currency;

  /// Whether this is the user's primary account.
  final bool isMain;

  /// Whether the balance is negative.
  bool get isNegative => balance < 0;

  /// Masked IBAN showing only the last 4 characters.
  String get maskedIban {
    if (iban.length <= 4) return iban;
    return '**** ${iban.substring(iban.length - 4)}';
  }

  /// Creates a copy with optionally overridden fields.
  Account copyWith({
    String? id,
    AccountType? type,
    String? name,
    String? iban,
    double? balance,
    String? currency,
    bool? isMain,
  }) {
    return Account(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      iban: iban ?? this.iban,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isMain: isMain ?? this.isMain,
    );
  }

  @override
  List<Object?> get props => [id, type, name, iban, balance, currency, isMain];
}
