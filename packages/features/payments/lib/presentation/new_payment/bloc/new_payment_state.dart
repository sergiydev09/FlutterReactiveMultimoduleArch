part of 'new_payment_bloc.dart';

enum NewPaymentStatus { initial, review, processing, success, error }

@freezed
abstract class NewPaymentState with _$NewPaymentState {
  const factory NewPaymentState({
    @Default(NewPaymentStatus.initial) NewPaymentStatus status,
    Payment? payment,
    String? confirmationId,
    @Default('') String errorMessage,
  }) = _NewPaymentState;
}
