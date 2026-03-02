import 'package:accounts/domain/usecases/get_account_detail_usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'account_detail_event.dart';
part 'account_detail_state.dart';

/// BLoC for loading account detail information.
class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  AccountDetailBloc({
    required GetAccountDetailUseCase getAccountDetailUseCase,
  }) : _getAccountDetailUseCase = getAccountDetailUseCase,
       super(const AccountDetailInitial()) {
    on<LoadAccountDetail>(_onLoad);
  }

  final GetAccountDetailUseCase _getAccountDetailUseCase;

  Future<void> _onLoad(
    LoadAccountDetail event,
    Emitter<AccountDetailState> emit,
  ) async {
    emit(const AccountDetailLoading());

    final result = await _getAccountDetailUseCase(event.accountId);

    result.match(
      (failure) => emit(AccountDetailError(message: failure.message)),
      (account) => emit(AccountDetailLoaded(account: account)),
    );
  }
}
