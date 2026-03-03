part of 'account_detail_bloc.dart';

@freezed
sealed class AccountDetailState with _$AccountDetailState {
  const factory AccountDetailState.initial() = AccountDetailInitial;

  const factory AccountDetailState.loading() = AccountDetailLoading;

  const factory AccountDetailState.loaded({required Account account}) =
      AccountDetailLoaded;

  const factory AccountDetailState.error({required String message}) =
      AccountDetailError;
}
