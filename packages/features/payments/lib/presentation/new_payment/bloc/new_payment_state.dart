part of 'new_payment_bloc.dart';

enum NewPaymentStatus { initial, review, processing, success, error }

extension NewPaymentStatusX on NewPaymentStatus {
  bool get isInitial => this == NewPaymentStatus.initial;
  bool get isReview => this == NewPaymentStatus.review;
  bool get isProcessing => this == NewPaymentStatus.processing;
  bool get isSuccess => this == NewPaymentStatus.success;
  bool get isError => this == NewPaymentStatus.error;
}

@freezed
abstract class NewPaymentState with _$NewPaymentState {
  const factory NewPaymentState({
    @Default(NewPaymentStatus.initial) NewPaymentStatus status,
    Payment? payment,
    String? confirmationId,
    @Default('') String errorMessage,
  }) = _NewPaymentState;
}
