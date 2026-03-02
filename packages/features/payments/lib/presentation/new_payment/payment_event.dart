part of 'payment_bloc.dart';

/// Events for the payment BLoC.
sealed class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Submitted the payment form for review.
final class SubmitPayment extends PaymentEvent {
  const SubmitPayment({required this.payment});

  final Payment payment;

  @override
  List<Object?> get props => [payment];
}

/// User confirmed the payment after review.
final class ConfirmPayment extends PaymentEvent {
  const ConfirmPayment();
}

/// User wants to retry after an error.
final class RetryPayment extends PaymentEvent {
  const RetryPayment();
}

/// Resets the payment flow to the initial state.
final class ResetPayment extends PaymentEvent {
  const ResetPayment();
}
