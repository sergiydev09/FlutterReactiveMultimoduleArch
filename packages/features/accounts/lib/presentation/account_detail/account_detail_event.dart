part of 'account_detail_bloc.dart';

@freezed
sealed class AccountDetailEvent with _$AccountDetailEvent {
  const factory AccountDetailEvent.loadAccountDetail({
    required String accountId,
  }) = LoadAccountDetail;
}
