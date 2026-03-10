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
       super(const NewPaymentState()) {
    on<SubmitPayment>(_onSubmit);
    on<ConfirmPayment>(_onConfirm);
    on<RetryPayment>(_onRetry);
    on<ResetPayment>(_onReset);
  }

  final ExecutePaymentUseCase _executePaymentUseCase;

  Future<void> _onSubmit(
    SubmitPayment event,
    Emitter<NewPaymentState> emit,
  ) async {
    emit(state.copyWith(
      status: NewPaymentStatus.review,
      payment: event.payment,
    ));
  }

  Future<void> _onConfirm(
    ConfirmPayment event,
    Emitter<NewPaymentState> emit,
  ) async {
    if (state.payment == null) return;

    emit(state.copyWith(status: NewPaymentStatus.processing));

    final result = await _executePaymentUseCase(state.payment!);

    result.match(
      (failure) => emit(state.copyWith(
        status: NewPaymentStatus.error,
        errorMessage: failure.message,
      )),
      (confirmationId) => emit(state.copyWith(
        status: NewPaymentStatus.success,
        confirmationId: confirmationId,
      )),
    );
  }

  Future<void> _onRetry(
    RetryPayment event,
    Emitter<NewPaymentState> emit,
  ) async {
    if (state.payment != null) {
      emit(state.copyWith(status: NewPaymentStatus.review));
    } else {
      emit(const NewPaymentState());
    }
  }

  void _onReset(
    ResetPayment event,
    Emitter<NewPaymentState> emit,
  ) {
    emit(const NewPaymentState());
  }
}
