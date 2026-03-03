import 'package:accounts/domain/usecases/get_account_transactions_usecase.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_transactions_event.dart';
part 'account_transactions_state.dart';
part 'generated/account_transactions_bloc.freezed.dart';

/// BLoC for loading and paginating account transactions.
class AccountTransactionsBloc
    extends Bloc<AccountTransactionsEvent, AccountTransactionsState> {
  AccountTransactionsBloc({
    required GetAccountTransactionsUseCase getAccountTransactionsUseCase,
  }) : _getAccountTransactionsUseCase = getAccountTransactionsUseCase,
       super(const AccountTransactionsInitial()) {
    on<LoadTransactions>(_onLoad);
    on<LoadMoreTransactions>(_onLoadMore);
  }

  final GetAccountTransactionsUseCase _getAccountTransactionsUseCase;

  Future<void> _onLoad(
    LoadTransactions event,
    Emitter<AccountTransactionsState> emit,
  ) async {
    emit(const AccountTransactionsLoading());

    final result = await _getAccountTransactionsUseCase(
      GetAccountTransactionsParams(accountId: event.accountId),
    );

    result.match(
      (failure) => emit(AccountTransactionsError(message: failure.message)),
      (transactions) => emit(
        AccountTransactionsLoaded(
          transactions: transactions,
          hasReachedMax: transactions.length < 20,
          currentPage: 0,
          accountId: event.accountId,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    LoadMoreTransactions event,
    Emitter<AccountTransactionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AccountTransactionsLoaded ||
        currentState.hasReachedMax) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _getAccountTransactionsUseCase(
      GetAccountTransactionsParams(
        accountId: currentState.accountId,
        page: nextPage,
      ),
    );

    result.match(
      (failure) => emit(AccountTransactionsError(message: failure.message)),
      (newTransactions) => emit(
        AccountTransactionsLoaded(
          transactions: [
            ...currentState.transactions,
            ...newTransactions,
          ],
          hasReachedMax: newTransactions.length < 20,
          currentPage: nextPage,
          accountId: currentState.accountId,
        ),
      ),
    );
  }
}
