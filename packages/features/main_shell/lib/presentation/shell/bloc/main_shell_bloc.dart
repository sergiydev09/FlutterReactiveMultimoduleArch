import 'package:common/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/shell_config.dart';
import '../../../domain/usecases/get_shell_config_usecase.dart';

part 'main_shell_event.dart';
part 'main_shell_state.dart';
part 'generated/main_shell_bloc.freezed.dart';

/// BLoC that loads the shell navigation configuration and handles logout.
class MainShellBloc extends Bloc<MainShellEvent, MainShellState> {
  MainShellBloc({
    required this.getShellConfigUseCase,
    required Future<void> Function() onLogout,
  })  : _onLogout = onLogout,
        super(const MainShellState()) {
    on<ShellStarted>(_onStarted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final GetShellConfigUseCase getShellConfigUseCase;
  final Future<void> Function() _onLogout;

  Future<void> _onStarted(
    ShellStarted event,
    Emitter<MainShellState> emit,
  ) async {
    emit(state.copyWith(status: MainShellStatus.loading));
    final result = await getShellConfigUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: MainShellStatus.error,
        errorMessage: failure.toString(),
      )),
      (config) => emit(state.copyWith(
        status: MainShellStatus.ready,
        config: config,
      )),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<MainShellState> emit,
  ) async {
    await _onLogout();
  }
}
