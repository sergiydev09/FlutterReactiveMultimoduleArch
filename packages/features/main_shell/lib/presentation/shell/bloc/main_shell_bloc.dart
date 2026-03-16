import 'package:common/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:security/security.dart';

import '../../../domain/entities/shell_config.dart';
import '../../../domain/usecases/get_shell_config_usecase.dart';

part 'main_shell_event.dart';
part 'main_shell_state.dart';
part 'generated/main_shell_bloc.freezed.dart';

/// BLoC that loads the shell navigation configuration and handles logout.
class MainShellBloc extends Bloc<MainShellEvent, MainShellState> {
  MainShellBloc({
    required GetShellConfigUseCase getShellConfigUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getShellConfigUseCase = getShellConfigUseCase,
        _logoutUseCase = logoutUseCase,
        super(const MainShellState()) {
    on<ShellStarted>(_onStarted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final GetShellConfigUseCase _getShellConfigUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onStarted(
    ShellStarted event,
    Emitter<MainShellState> emit,
  ) async {
    emit(state.copyWith(status: MainShellStatus.loading));
    final result = await _getShellConfigUseCase(const NoParams());
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
    final result = await _logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: MainShellStatus.error,
        errorMessage: failure.toString(),
      )),
      (_) {
        // Session cleared — GoRouter.redirect handles navigation automatically.
      },
    );
  }
}
