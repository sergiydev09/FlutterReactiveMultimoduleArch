part of 'new_payment_bloc.dart';

@freezed
sealed class NewPaymentEvent with _$NewPaymentEvent {
  const factory NewPaymentEvent.submitPayment({required Payment payment}) =
      SubmitPayment;

  const factory NewPaymentEvent.confirmPayment() = ConfirmPayment;

  const factory NewPaymentEvent.retryPayment() = RetryPayment;

  const factory NewPaymentEvent.resetPayment() = ResetPayment;
}
