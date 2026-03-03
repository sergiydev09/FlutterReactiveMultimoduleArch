part of 'payment_bloc.dart';

@freezed
sealed class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = PaymentInitial;

  const factory PaymentState.review({required Payment payment}) = PaymentReview;

  const factory PaymentState.processing() = PaymentProcessing;

  const factory PaymentState.success({required String confirmationId}) =
      PaymentSuccess;

  const factory PaymentState.error({required String message}) = PaymentError;
}
