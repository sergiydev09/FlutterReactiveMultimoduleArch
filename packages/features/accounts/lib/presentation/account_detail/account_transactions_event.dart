part of 'account_transactions_bloc.dart';

/// Events for the account transactions BLoC.
sealed class AccountTransactionsEvent extends Equatable {
  const AccountTransactionsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load the first page of transactions.
final class LoadTransactions extends AccountTransactionsEvent {
  const LoadTransactions({required this.accountId});

  final String accountId;

  @override
  List<Object?> get props => [accountId];
}

/// Triggered to load the next page of transactions.
final class LoadMoreTransactions extends AccountTransactionsEvent {
  const LoadMoreTransactions();
}
