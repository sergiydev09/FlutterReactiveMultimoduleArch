import 'package:domain/entities/account.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/account_dto.g.dart';

@JsonSerializable()
class AccountDto {
  const AccountDto({
    required this.id,
    required this.type,
    required this.name,
    required this.iban,
    required this.balance,
    this.currency = 'EUR',
    this.isMain = false,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) =>
      _$AccountDtoFromJson(json);

  final String id;
  final String type;
  final String name;
  final String iban;
  final double balance;
  final String currency;
  @JsonKey(name: 'is_main')
  final bool isMain;

  Map<String, dynamic> toJson() => _$AccountDtoToJson(this);

  Account toEntity() {
    return Account(
      id: id,
      type: _parseAccountType(type),
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
