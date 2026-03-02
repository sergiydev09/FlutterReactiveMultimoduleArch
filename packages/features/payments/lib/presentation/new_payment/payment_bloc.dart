import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payments/domain/entities/payment.dart';
import 'package:payments/domain/usecases/execute_payment_usecase.dart';

part 'payment_event.dart';
part 'payment_state.dart';

/// BLoC for the payment flow.
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required ExecutePaymentUseCase executePaymentUseCase,
  }) : _executePaymentUseCase = executePaymentUseCase,
       super(const PaymentInitial()) {
    on<SubmitPayment>(_onSubmit);
    on<ConfirmPayment>(_onConfirm);
    on<RetryPayment>(_onRetry);
    on<ResetPayment>(_onReset);
  }

  final ExecutePaymentUseCase _executePaymentUseCase;
  Payment? _currentPayment;

  Future<void> _onSubmit(
    SubmitPayment event,
    Emitter<PaymentState> emit,
  ) async {
    _currentPayment = event.payment;
    emit(PaymentReview(payment: event.payment));
  }

  Future<void> _onConfirm(
    ConfirmPayment event,
    Emitter<PaymentState> emit,
  ) async {
    if (_currentPayment == null) return;

    emit(const PaymentProcessing());

    final result = await _executePaymentUseCase(_currentPayment!);

    result.match(
      (failure) => emit(PaymentError(message: failure.message)),
      (confirmationId) => emit(
        PaymentSuccess(confirmationId: confirmationId),
      ),
    );
  }

  Future<void> _onRetry(
    RetryPayment event,
    Emitter<PaymentState> emit,
  ) async {
    if (_currentPayment != null) {
      emit(PaymentReview(payment: _currentPayment!));
    } else {
      emit(const PaymentInitial());
    }
  }

  void _onReset(
    ResetPayment event,
    Emitter<PaymentState> emit,
  ) {
    _currentPayment = null;
    emit(const PaymentInitial());
  }
}
