import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:security/session/session_manager.dart';

import '../../../domain/usecases/get_transaction_detail_url_usecase.dart';

part 'transaction_web_detail_event.dart';
part 'transaction_web_detail_state.dart';
part 'generated/transaction_web_detail_bloc.freezed.dart';

/// BLoC for the WebView-based transaction detail screen.
///
/// Coordinates two async operations before the WebView can be shown:
/// 1. Fetches the WebView URL via [GetTransactionDetailUrlUseCase].
/// 2. Reads the session token via [SessionManager] for the JS bridge
///    `initialData` payload.
///
/// Both operations run in [_onStarted] so the page receives a single,
/// consistent loaded state instead of managing two separate async calls.
class TransactionWebDetailBloc
    extends Bloc<TransactionWebDetailEvent, TransactionWebDetailState> {
  TransactionWebDetailBloc({
    required GetTransactionDetailUrlUseCase getTransactionDetailUrlUseCase,
    required SessionManager sessionManager,
  })  : _getUrlUseCase = getTransactionDetailUrlUseCase,
        _sessionManager = sessionManager,
        super(const TransactionWebDetailState()) {
    on<TransactionWebDetailStarted>(_onStarted);
  }

  final GetTransactionDetailUrlUseCase _getUrlUseCase;
  final SessionManager _sessionManager;

  Future<void> _onStarted(
    TransactionWebDetailStarted event,
    Emitter<TransactionWebDetailState> emit,
  ) async {
    emit(state.copyWith(status: TransactionWebDetailStatus.loading));

    final urlResult = await _getUrlUseCase(event.transactionId);

    await urlResult.match(
      (failure) async => emit(state.copyWith(
        status: TransactionWebDetailStatus.error,
        errorMessage: failure.message,
      )),
      (url) async {
        final token = await _sessionManager.getToken();
        emit(state.copyWith(
          status: TransactionWebDetailStatus.loaded,
          url: url,
          token: token,
        ));
      },
    );
  }
}
