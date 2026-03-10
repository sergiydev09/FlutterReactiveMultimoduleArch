part of 'account_transactions_bloc.dart';

enum AccountTransactionsStatus { initial, loading, loaded, error }

@freezed
abstract class AccountTransactionsState with _$AccountTransactionsState {
  const factory AccountTransactionsState({
    @Default(AccountTransactionsStatus.initial)
    AccountTransactionsStatus status,
    @Default([]) List<Transaction> transactions,
    @Default(false) bool hasReachedMax,
    @Default(0) int currentPage,
    @Default('') String accountId,
    @Default('') String errorMessage,
  }) = _AccountTransactionsState;
}
