import 'package:domain/entities/account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/usecases/get_account_detail_usecase.dart';

part 'account_detail_event.dart';
part 'account_detail_state.dart';
part 'generated/account_detail_bloc.freezed.dart';

/// BLoC for loading account detail information.
class AccountDetailBloc extends Bloc<AccountDetailEvent, AccountDetailState> {
  AccountDetailBloc({
    required GetAccountDetailUseCase getAccountDetailUseCase,
  }) : _getAccountDetailUseCase = getAccountDetailUseCase,
       super(const AccountDetailState()) {
    on<LoadAccountDetail>(_onLoad);
  }

  final GetAccountDetailUseCase _getAccountDetailUseCase;

  Future<void> _onLoad(
    LoadAccountDetail event,
    Emitter<AccountDetailState> emit,
  ) async {
    emit(state.copyWith(status: AccountDetailStatus.loading));

    final result = await _getAccountDetailUseCase(event.accountId);

    result.match(
      (failure) => emit(state.copyWith(
        status: AccountDetailStatus.error,
        errorMessage: failure.message,
      )),
      (account) => emit(state.copyWith(
        status: AccountDetailStatus.loaded,
        account: account,
      )),
    );
  }
}
