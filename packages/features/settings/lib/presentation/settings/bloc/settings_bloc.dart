import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'generated/settings_bloc.freezed.dart';

/// BLoC for managing user settings/preferences.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    bool initialBiometricEnabled = false,
    VoidCallback? onBiometricToggle,
  }) : _onBiometricToggle = onBiometricToggle,
       super(SettingsState(isBiometricsEnabled: initialBiometricEnabled)) {
    on<ToggleTheme>(_onToggleTheme);
    on<ToggleBiometrics>(_onToggleBiometrics);
    on<ToggleNotifications>(_onToggleNotifications);
  }

  final VoidCallback? _onBiometricToggle;

  void _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void _onToggleBiometrics(
    ToggleBiometrics event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(isBiometricsEnabled: !state.isBiometricsEnabled));
    _onBiometricToggle?.call();
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
}
