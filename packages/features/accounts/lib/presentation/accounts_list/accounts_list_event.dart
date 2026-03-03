part of 'accounts_list_bloc.dart';

@freezed
sealed class AccountsListEvent with _$AccountsListEvent {
  const factory AccountsListEvent.loadAccounts() = LoadAccounts;
}
