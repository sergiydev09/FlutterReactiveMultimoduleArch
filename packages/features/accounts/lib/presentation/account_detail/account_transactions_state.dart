part of 'account_transactions_bloc.dart';

/// States for the account transactions BLoC.
sealed class AccountTransactionsState extends Equatable {
  const AccountTransactionsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
final class AccountTransactionsInitial extends AccountTransactionsState {
  const AccountTransactionsInitial();
}

/// Transactions are being loaded for the first time.
final class AccountTransactionsLoading extends AccountTransactionsState {
  const AccountTransactionsLoading();
}

/// Transactions loaded successfully.
final class AccountTransactionsLoaded extends AccountTransactionsState {
  const AccountTransactionsLoaded({
    required this.transactions,
    required this.hasReachedMax,
    required this.currentPage,
    required this.accountId,
  });

  /// All loaded transactions so far.
  final List<Transaction> transactions;

  /// Whether there are no more pages to load.
  final bool hasReachedMax;

  /// Current page index.
  final int currentPage;

  /// The account ID these transactions belong to.
  final String accountId;

  @override
  List<Object?> get props =>
      [transactions, hasReachedMax, currentPage, accountId];
}

/// Error loading transactions.
final class AccountTransactionsError extends AccountTransactionsState {
  const AccountTransactionsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
