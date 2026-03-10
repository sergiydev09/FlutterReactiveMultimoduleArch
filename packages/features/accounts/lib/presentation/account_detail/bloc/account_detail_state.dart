part of 'account_detail_bloc.dart';

enum AccountDetailStatus { initial, loading, loaded, error }

@freezed
abstract class AccountDetailState with _$AccountDetailState {
  const factory AccountDetailState({
    @Default(AccountDetailStatus.initial) AccountDetailStatus status,
    Account? account,
    @Default('') String errorMessage,
  }) = _AccountDetailState;
}
