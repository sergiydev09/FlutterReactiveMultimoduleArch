part of 'transaction_web_detail_bloc.dart';

@freezed
sealed class TransactionWebDetailEvent with _$TransactionWebDetailEvent {
  const factory TransactionWebDetailEvent.started({
    required String transactionId,
  }) = TransactionWebDetailStarted;
}
