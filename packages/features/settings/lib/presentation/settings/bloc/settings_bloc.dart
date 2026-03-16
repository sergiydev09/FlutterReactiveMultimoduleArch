import 'package:common/usecases/usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:security/security.dart';
import '../../../domain/usecases/get_biometrics_status_usecase.dart';
import '../../../domain/usecases/toggle_biometrics_usecase.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'generated/settings_bloc.freezed.dart';

/// BLoC for managing user settings/preferences.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required GetBiometricsStatusUseCase getBiometricsStatusUseCase,
    required ToggleBiometricsUseCase toggleBiometricsUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _getBiometricsStatusUseCase = getBiometricsStatusUseCase,
        _toggleBiometricsUseCase = toggleBiometricsUseCase,
        _logoutUseCase = logoutUseCase,
        super(const SettingsState()) {
    on<SettingsStarted>(_onSettingsStarted);
    on<ToggleTheme>(_onToggleTheme);
    on<ToggleBiometrics>(_onToggleBiometrics);
    on<ToggleNotifications>(_onToggleNotifications);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final GetBiometricsStatusUseCase _getBiometricsStatusUseCase;
  final ToggleBiometricsUseCase _toggleBiometricsUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onSettingsStarted(
    SettingsStarted event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final result = await _getBiometricsStatusUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (isEnabled) => emit(
        state.copyWith(
          status: SettingsStatus.loaded,
          isBiometricsEnabled: isEnabled,
        ),
      ),
    );
  }

  void _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  Future<void> _onToggleBiometrics(
    ToggleBiometrics event,
    Emitter<SettingsState> emit,
  ) async {
    final result = await _toggleBiometricsUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (newValue) => emit(
        state.copyWith(
          status: SettingsStatus.loaded,
          isBiometricsEnabled: newValue,
        ),
      ),
    );
  }

  void _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) {
    emit(
      state.copyWith(
        areNotificationsEnabled: !state.areNotificationsEnabled,
      ),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loggingOut));
    final result = await _logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SettingsStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        // Session cleared — GoRouter.redirect handles navigation automatically.
      },
    );
  }
}
