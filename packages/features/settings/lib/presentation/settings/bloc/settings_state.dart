part of 'settings_bloc.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isDarkMode,
    @Default(false) bool isBiometricsEnabled,
    @Default(true) bool areNotificationsEnabled,
  }) = _SettingsState;
}
