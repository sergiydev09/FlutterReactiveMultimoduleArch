part of 'account_transactions_bloc.dart';

@freezed
sealed class AccountTransactionsEvent with _$AccountTransactionsEvent {
  const factory AccountTransactionsEvent.loadTransactions({
    required String accountId,
  }) = LoadTransactions;

  const factory AccountTransactionsEvent.loadMoreTransactions() =
      LoadMoreTransactions;
}
