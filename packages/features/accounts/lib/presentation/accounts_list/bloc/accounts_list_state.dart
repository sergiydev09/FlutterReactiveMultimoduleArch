part of 'accounts_list_bloc.dart';

enum AccountsListStatus { initial, loading, loaded, error }

@freezed
abstract class AccountsListState with _$AccountsListState {
  const factory AccountsListState({
    @Default(AccountsListStatus.initial) AccountsListStatus status,
    @Default([]) List<Account> accounts,
    @Default('') String errorMessage,
  }) = _AccountsListState;
}
