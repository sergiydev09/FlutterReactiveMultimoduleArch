import 'package:equatable/equatable.dart';

/// Represents a payment to be executed.
class Payment extends Equatable {
  const Payment({
    required this.fromAccount,
    required this.toIban,
    required this.amount,
    required this.concept,
  });

  /// Source account ID.
  final String fromAccount;

  /// Destination IBAN.
  final String toIban;

  /// Amount to transfer.
  final double amount;

  /// Payment concept / description.
  final String concept;

  @override
  List<Object?> get props => [fromAccount, toIban, amount, concept];
}
