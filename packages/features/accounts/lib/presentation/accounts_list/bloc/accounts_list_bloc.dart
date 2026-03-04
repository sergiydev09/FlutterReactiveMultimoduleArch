import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/usecases/get_accounts_usecase.dart';

part 'accounts_list_event.dart';
part 'accounts_list_state.dart';
part 'generated/accounts_list_bloc.freezed.dart';

/// BLoC responsible for loading the accounts list.
class AccountsListBloc extends Bloc<AccountsListEvent, AccountsListState> {
  AccountsListBloc({
    required GetAccountsUseCase getAccountsUseCase,
  }) : _getAccountsUseCase = getAccountsUseCase,
       super(const AccountsListInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
  }

  final GetAccountsUseCase _getAccountsUseCase;

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountsListState> emit,
  ) async {
    emit(const AccountsListLoading());

    final result = await _getAccountsUseCase(const NoParams());

    result.match(
      (failure) => emit(AccountsListError(message: failure.message)),
      (accounts) => emit(AccountsListLoaded(accounts: accounts)),
    );
  }
}
