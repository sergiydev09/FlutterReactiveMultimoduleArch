import 'package:domain/entities/transaction.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/transaction_dto.g.dart';

@JsonSerializable()
class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.currency = 'EUR',
    this.category = 'other',
    this.status = 'completed',
    this.merchant,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionDtoFromJson(json);

  final String id;
  @JsonKey(name: 'account_id')
  final String accountId;
  final double amount;
  final String currency;
  final String description;
  final String category;
  final String status;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final String? merchant;

  Map<String, dynamic> toJson() => _$TransactionDtoToJson(this);

  Transaction toEntity() {
    return Transaction(
      id: id,
      accountId: accountId,
      amount: amount,
      currency: currency,
      description: description,
      category: _parseCategory(category),
      status: _parseStatus(status),
      createdAt: DateTime.parse(createdAt),
      merchant: merchant,
    );
  }

  static TransactionCategory _parseCategory(String category) {
    return switch (category.toLowerCase()) {
      'salary' => TransactionCategory.salary,
      'transfer' => TransactionCategory.transfer,
      'shopping' => TransactionCategory.shopping,
      'food' => TransactionCategory.food,
      'transport' => TransactionCategory.transport,
      'entertainment' => TransactionCategory.entertainment,
      'bills' => TransactionCategory.bills,
      'health' => TransactionCategory.health,
      'atm' => TransactionCategory.atm,
      _ => TransactionCategory.other,
    };
  }

  static TransactionStatus _parseStatus(String status) {
    return switch (status.toLowerCase()) {
      'pending' => TransactionStatus.pending,
      'completed' => TransactionStatus.completed,
      'failed' => TransactionStatus.failed,
      'cancelled' => TransactionStatus.cancelled,
      _ => TransactionStatus.completed,
    };
  }
}
