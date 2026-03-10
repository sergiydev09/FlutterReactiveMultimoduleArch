import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/usecases/get_global_position_usecase.dart';

part 'global_position_event.dart';
part 'global_position_state.dart';
part 'generated/global_position_bloc.freezed.dart';

/// BLoC for the global position (home) screen.
class GlobalPositionBloc
    extends Bloc<GlobalPositionEvent, GlobalPositionState> {
  GlobalPositionBloc({
    required GetGlobalPositionUseCase getGlobalPositionUseCase,
  }) : _getGlobalPositionUseCase = getGlobalPositionUseCase,
       super(const GlobalPositionState()) {
    on<LoadGlobalPosition>(_onLoad, transformer: droppable());
    on<RefreshGlobalPosition>(_onRefresh, transformer: droppable());
  }

  final GetGlobalPositionUseCase _getGlobalPositionUseCase;

  Future<void> _onLoad(
    LoadGlobalPosition event,
    Emitter<GlobalPositionState> emit,
  ) async {
    emit(state.copyWith(status: GlobalPositionStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
    RefreshGlobalPosition event,
    Emitter<GlobalPositionState> emit,
  ) async {
    await _fetchData(emit);
  }

  Future<void> _fetchData(Emitter<GlobalPositionState> emit) async {
    final result = await _getGlobalPositionUseCase(const NoParams());

    result.match(
      (failure) => emit(state.copyWith(
        status: GlobalPositionStatus.error,
        errorMessage: failure.message,
      )),
      (data) => emit(state.copyWith(
        status: GlobalPositionStatus.loaded,
        accounts: data.accounts,
        transactions: data.recentTransactions,
        userName: 'Usuario',
      )),
    );
  }
}
