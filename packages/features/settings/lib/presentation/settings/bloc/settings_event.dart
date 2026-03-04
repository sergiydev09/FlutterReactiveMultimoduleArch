part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.toggleTheme() = ToggleTheme;

  const factory SettingsEvent.toggleBiometrics() = ToggleBiometrics;

  const factory SettingsEvent.toggleNotifications() = ToggleNotifications;
}
