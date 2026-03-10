import 'package:domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/usecases/get_account_transactions_usecase.dart';

part 'account_transactions_event.dart';
part 'account_transactions_state.dart';
part 'generated/account_transactions_bloc.freezed.dart';

/// BLoC for loading and paginating account transactions.
class AccountTransactionsBloc
    extends Bloc<AccountTransactionsEvent, AccountTransactionsState> {
  AccountTransactionsBloc({
    required GetAccountTransactionsUseCase getAccountTransactionsUseCase,
  }) : _getAccountTransactionsUseCase = getAccountTransactionsUseCase,
       super(const AccountTransactionsState()) {
    on<LoadTransactions>(_onLoad);
    on<LoadMoreTransactions>(_onLoadMore);
  }

  final GetAccountTransactionsUseCase _getAccountTransactionsUseCase;

  Future<void> _onLoad(
    LoadTransactions event,
    Emitter<AccountTransactionsState> emit,
  ) async {
    emit(state.copyWith(status: AccountTransactionsStatus.loading));

    final result = await _getAccountTransactionsUseCase(
      GetAccountTransactionsParams(accountId: event.accountId),
    );

    result.match(
      (failure) => emit(state.copyWith(
        status: AccountTransactionsStatus.error,
        errorMessage: failure.message,
      )),
      (transactions) => emit(state.copyWith(
        status: AccountTransactionsStatus.loaded,
        transactions: transactions,
        hasReachedMax: transactions.length < 20,
        currentPage: 0,
        accountId: event.accountId,
      )),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreTransactions event,
    Emitter<AccountTransactionsState> emit,
  ) async {
    if (state.status != AccountTransactionsStatus.loaded ||
        state.hasReachedMax) {
      return;
    }

    final nextPage = state.currentPage + 1;

    final result = await _getAccountTransactionsUseCase(
      GetAccountTransactionsParams(
        accountId: state.accountId,
        page: nextPage,
      ),
    );

    result.match(
      (failure) => emit(state.copyWith(
        status: AccountTransactionsStatus.error,
        errorMessage: failure.message,
      )),
      (newTransactions) => emit(state.copyWith(
        transactions: [
          ...state.transactions,
          ...newTransactions,
        ],
        hasReachedMax: newTransactions.length < 20,
        currentPage: nextPage,
      )),
    );
  }
}
