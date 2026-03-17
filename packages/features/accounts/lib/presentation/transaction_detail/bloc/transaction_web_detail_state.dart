part of 'transaction_web_detail_bloc.dart';

enum TransactionWebDetailStatus { initial, loading, loaded, error }

extension TransactionWebDetailStatusX on TransactionWebDetailStatus {
  bool get isInitial => this == TransactionWebDetailStatus.initial;
  bool get isLoading => this == TransactionWebDetailStatus.loading;
  bool get isLoaded => this == TransactionWebDetailStatus.loaded;
  bool get isError => this == TransactionWebDetailStatus.error;
}

@freezed
abstract class TransactionWebDetailState with _$TransactionWebDetailState {
  const factory TransactionWebDetailState({
    @Default(TransactionWebDetailStatus.initial) TransactionWebDetailStatus status,
    String? url,
    String? token,
    @Default('') String errorMessage,
  }) = _TransactionWebDetailState;
}
