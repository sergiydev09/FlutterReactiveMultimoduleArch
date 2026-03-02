import 'package:equatable/equatable.dart';

/// Transaction status.
enum TransactionStatus {
  /// Transaction is being processed.
  pending,

  /// Transaction completed successfully.
  completed,

  /// Transaction was rejected or failed.
  failed,

  /// Transaction was cancelled.
  cancelled,
}

/// Transaction category for grouping and reporting.
enum TransactionCategory {
  /// Salary, wages, freelance income.
  salary,

  /// Transfer between own accounts.
  transfer,

  /// Shopping, retail purchases.
  shopping,

  /// Food, restaurants, groceries.
  food,

  /// Transportation, fuel, public transit.
  transport,

  /// Entertainment, subscriptions.
  entertainment,

  /// Utilities, rent, insurance.
  bills,

  /// Health, pharmacy.
  health,

  /// ATM withdrawal / deposit.
  atm,

  /// Uncategorized.
  other,
}

/// Represents a financial transaction on an account.
class Transaction extends Equatable {
  const Transaction({
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

  /// Unique transaction identifier.
  final String id;

  /// The account this transaction belongs to.
  final String accountId;

  /// Amount (positive = credit, negative = debit).
  final double amount;

  /// ISO 4217 currency code.
  final String currency;

  /// Human-readable description.
  final String description;

  /// Transaction category.
  final TransactionCategory category;

  /// Current status.
  final TransactionStatus status;

  /// When the transaction was created.
  final DateTime createdAt;

  /// Merchant name, if applicable.
  final String? merchant;

  /// Whether this is an income (positive amount).
  bool get isIncome => amount >= 0;

  /// Whether this is an expense (negative amount).
  bool get isExpense => amount < 0;

  /// Creates a copy with optionally overridden fields.
  Transaction copyWith({
    String? id,
    String? accountId,
    double? amount,
    String? currency,
    String? description,
    TransactionCategory? category,
    TransactionStatus? status,
    DateTime? createdAt,
    String? merchant,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      merchant: merchant ?? this.merchant,
    );
  }

  @override
  List<Object?> get props => [
    id,
    accountId,
    amount,
    currency,
    description,
    category,
    status,
    createdAt,
    merchant,
  ];
}
