import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'generated/settings_bloc.freezed.dart';

/// BLoC for managing user settings/preferences.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<ToggleTheme>(_onToggleTheme);
    on<ToggleBiometrics>(_onToggleBiometrics);
    on<ToggleNotifications>(_onToggleNotifications);
  }

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
