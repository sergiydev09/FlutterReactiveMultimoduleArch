part of 'accounts_list_bloc.dart';

@freezed
sealed class AccountsListState with _$AccountsListState {
  const factory AccountsListState.initial() = AccountsListInitial;

  const factory AccountsListState.loading() = AccountsListLoading;

  const factory AccountsListState.loaded({
    required List<Account> accounts,
  }) = AccountsListLoaded;

  const factory AccountsListState.error({required String message}) =
      AccountsListError;
}
