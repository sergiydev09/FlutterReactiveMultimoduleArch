import 'package:domain/entities/account.dart';

/// Data model for [Account] with JSON deserialization.
class AccountModel {
  const AccountModel({
    required this.id,
    required this.type,
    required this.name,
    required this.iban,
    required this.balance,
    required this.currency,
    this.isMain = false,
  });

  /// Creates an [AccountModel] from a JSON map.
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      type: _parseAccountType(json['type'] as String),
      name: json['name'] as String,
      iban: json['iban'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      isMain: json['is_main'] as bool? ?? false,
    );
  }

  final String id;
  final AccountType type;
  final String name;
  final String iban;
  final double balance;
  final String currency;
  final bool isMain;

  /// Converts this model to a domain entity.
  Account toEntity() {
    return Account(
      id: id,
      type: type,
      name: name,
      iban: iban,
      balance: balance,
      currency: currency,
      isMain: isMain,
    );
  }

  static AccountType _parseAccountType(String type) {
    return switch (type.toLowerCase()) {
      'current' || 'checking' => AccountType.current,
      'savings' => AccountType.savings,
      'investment' => AccountType.investment,
      _ => AccountType.current,
    };
  }
}
