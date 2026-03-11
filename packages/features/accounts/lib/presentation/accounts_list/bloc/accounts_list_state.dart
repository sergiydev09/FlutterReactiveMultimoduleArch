part of 'accounts_list_bloc.dart';

enum AccountsListStatus { initial, loading, loaded, error }

extension AccountsListStatusX on AccountsListStatus {
  bool get isInitial => this == AccountsListStatus.initial;
  bool get isLoading => this == AccountsListStatus.loading;
  bool get isLoaded => this == AccountsListStatus.loaded;
  bool get isError => this == AccountsListStatus.error;
}

@freezed
abstract class AccountsListState with _$AccountsListState {
  const factory AccountsListState({
    @Default(AccountsListStatus.initial) AccountsListStatus status,
    @Default([]) List<Account> accounts,
    @Default('') String errorMessage,
  }) = _AccountsListState;
}
