part of 'new_payment_bloc.dart';

@freezed
sealed class NewPaymentState with _$NewPaymentState {
  const factory NewPaymentState.initial() = NewPaymentInitial;

  const factory NewPaymentState.review({required Payment payment}) =
      NewPaymentReview;

  const factory NewPaymentState.processing() = NewPaymentProcessing;

  const factory NewPaymentState.success({required String confirmationId}) =
      NewPaymentSuccess;

  const factory NewPaymentState.error({required String message}) =
      NewPaymentError;
}
