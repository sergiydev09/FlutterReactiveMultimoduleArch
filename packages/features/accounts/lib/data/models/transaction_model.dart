import 'package:domain/entities/transaction.dart';

/// Data model for [Transaction] with JSON deserialization.
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.accountId,
    required this.amount,
    required this.currency,
    required this.description,
    required this.category,
    required this.status,
    required this.createdAt,
    this.merchant,
  });

  /// Creates a [TransactionModel] from a JSON map.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      description: json['description'] as String,
      category: _parseCategory(json['category'] as String? ?? 'other'),
      status: _parseStatus(json['status'] as String? ?? 'completed'),
      createdAt: DateTime.parse(json['created_at'] as String),
      merchant: json['merchant'] is Map<String, dynamic>
          ? (json['merchant'] as Map<String, dynamic>)['name'] as String?
          : json['merchant'] as String?,
    );
  }

  final String id;
  final String accountId;
  final double amount;
  final String currency;
  final String description;
  final TransactionCategory category;
  final TransactionStatus status;
  final DateTime createdAt;
  final String? merchant;

  /// Converts this model to a domain entity.
  Transaction toEntity() {
    return Transaction(
      id: id,
      accountId: accountId,
      amount: amount,
      currency: currency,
      description: description,
      category: category,
      status: status,
      createdAt: createdAt,
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
