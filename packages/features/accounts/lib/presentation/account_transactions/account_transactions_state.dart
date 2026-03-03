part of 'account_transactions_bloc.dart';

@freezed
sealed class AccountTransactionsState with _$AccountTransactionsState {
  const factory AccountTransactionsState.initial() =
      AccountTransactionsInitial;

  const factory AccountTransactionsState.loading() =
      AccountTransactionsLoading;

  const factory AccountTransactionsState.loaded({
    required List<Transaction> transactions,
    required bool hasReachedMax,
    required int currentPage,
    required String accountId,
  }) = AccountTransactionsLoaded;

  const factory AccountTransactionsState.error({required String message}) =
      AccountTransactionsError;
}
