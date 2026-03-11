part of 'account_detail_bloc.dart';

enum AccountDetailStatus { initial, loading, loaded, error }

extension AccountDetailStatusX on AccountDetailStatus {
  bool get isInitial => this == AccountDetailStatus.initial;
  bool get isLoading => this == AccountDetailStatus.loading;
  bool get isLoaded => this == AccountDetailStatus.loaded;
  bool get isError => this == AccountDetailStatus.error;
}

@freezed
abstract class AccountDetailState with _$AccountDetailState {
  const factory AccountDetailState({
    @Default(AccountDetailStatus.initial) AccountDetailStatus status,
    Account? account,
    @Default('') String errorMessage,
  }) = _AccountDetailState;
}
