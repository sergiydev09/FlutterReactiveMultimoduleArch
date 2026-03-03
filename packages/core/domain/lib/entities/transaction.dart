import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/transaction.freezed.dart';

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
@freezed
abstract class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String accountId,
    required double amount,
    required String currency,
    required String description,
    required TransactionCategory category,
    required TransactionStatus status,
    required DateTime createdAt,
    String? merchant,
  }) = _Transaction;

  const Transaction._();

  /// Whether this is an income (positive amount).
  bool get isIncome => amount >= 0;

  /// Whether this is an expense (negative amount).
  bool get isExpense => amount < 0;
}
