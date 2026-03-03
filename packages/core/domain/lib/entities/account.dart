import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/account.freezed.dart';

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
@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required AccountType type,
    required String name,
    required String iban,
    required double balance,
    required String currency,
    @Default(false) bool isMain,
  }) = _Account;

  const Account._();

  /// Whether the balance is negative.
  bool get isNegative => balance < 0;

  /// Masked IBAN showing only the last 4 characters.
  String get maskedIban {
    if (iban.length <= 4) return iban;
    return '**** ${iban.substring(iban.length - 4)}';
  }
}
