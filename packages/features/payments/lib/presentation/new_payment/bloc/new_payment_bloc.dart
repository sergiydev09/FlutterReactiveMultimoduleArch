import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/usecases/execute_payment_usecase.dart';

part 'new_payment_event.dart';
part 'new_payment_state.dart';
part 'generated/new_payment_bloc.freezed.dart';

/// BLoC for the payment flow.
class NewPaymentBloc extends Bloc<NewPaymentEvent, NewPaymentState> {
  NewPaymentBloc({
    required ExecutePaymentUseCase executePaymentUseCase,
  }) : _executePaymentUseCase = executePaymentUseCase,
       super(const NewPaymentInitial()) {
    on<SubmitPayment>(_onSubmit);
    on<ConfirmPayment>(_onConfirm);
    on<RetryPayment>(_onRetry);
    on<ResetPayment>(_onReset);
  }

  final ExecutePaymentUseCase _executePaymentUseCase;
  Payment? _currentPayment;

  Future<void> _onSubmit(
    SubmitPayment event,
    Emitter<NewPaymentState> emit,
  ) async {
    _currentPayment = event.payment;
    emit(NewPaymentReview(payment: event.payment));
  }

  Future<void> _onConfirm(
    ConfirmPayment event,
    Emitter<NewPaymentState> emit,
  ) async {
    if (_currentPayment == null) return;

    emit(const NewPaymentProcessing());

    final result = await _executePaymentUseCase(_currentPayment!);

    result.match(
      (failure) => emit(NewPaymentError(message: failure.message)),
      (confirmationId) => emit(
        NewPaymentSuccess(confirmationId: confirmationId),
      ),
    );
  }

  Future<void> _onRetry(
    RetryPayment event,
    Emitter<NewPaymentState> emit,
  ) async {
    if (_currentPayment != null) {
      emit(NewPaymentReview(payment: _currentPayment!));
    } else {
      emit(const NewPaymentInitial());
    }
  }

  void _onReset(
    ResetPayment event,
    Emitter<NewPaymentState> emit,
  ) {
    _currentPayment = null;
    emit(const NewPaymentInitial());
  }
}
