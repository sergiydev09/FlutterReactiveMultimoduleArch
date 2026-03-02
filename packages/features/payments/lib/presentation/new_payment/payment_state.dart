part of 'payment_bloc.dart';

/// States for the payment BLoC.
sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state - payment form.
final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Payment details under review before confirmation.
final class PaymentReview extends PaymentState {
  const PaymentReview({required this.payment});

  final Payment payment;

  @override
  List<Object?> get props => [payment];
}

/// Payment is being processed.
final class PaymentProcessing extends PaymentState {
  const PaymentProcessing();
}

/// Payment completed successfully.
final class PaymentSuccess extends PaymentState {
  const PaymentSuccess({required this.confirmationId});

  /// The unique confirmation ID for the payment.
  final String confirmationId;

  @override
  List<Object?> get props => [confirmationId];
}

/// Payment failed with an error.
final class PaymentError extends PaymentState {
  const PaymentError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
