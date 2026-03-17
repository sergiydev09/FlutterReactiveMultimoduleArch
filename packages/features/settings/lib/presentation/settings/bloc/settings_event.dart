part of 'settings_bloc.dart';

@freezed
sealed class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.settingsStarted() = SettingsStarted;

  const factory SettingsEvent.toggleTheme() = ToggleTheme;

  const factory SettingsEvent.toggleBiometrics() = ToggleBiometrics;

  const factory SettingsEvent.toggleNotifications() = ToggleNotifications;

  const factory SettingsEvent.logoutRequested() = LogoutRequested;
}
