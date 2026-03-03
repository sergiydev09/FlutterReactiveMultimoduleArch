part of 'payment_bloc.dart';

@freezed
sealed class PaymentEvent with _$PaymentEvent {
  const factory PaymentEvent.submitPayment({required Payment payment}) =
      SubmitPayment;

  const factory PaymentEvent.confirmPayment() = ConfirmPayment;

  const factory PaymentEvent.retryPayment() = RetryPayment;

  const factory PaymentEvent.resetPayment() = ResetPayment;
}
