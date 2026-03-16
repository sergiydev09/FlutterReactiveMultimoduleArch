part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, loaded, loggingOut, error }

extension SettingsStatusX on SettingsStatus {
  bool get isInitial => this == SettingsStatus.initial;
  bool get isLoading => this == SettingsStatus.loading;
  bool get isLoaded => this == SettingsStatus.loaded;
  bool get isLoggingOut => this == SettingsStatus.loggingOut;
  bool get isError => this == SettingsStatus.error;
}

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(SettingsStatus.initial) SettingsStatus status,
    @Default(false) bool isDarkMode,
    @Default(false) bool isBiometricsEnabled,
    @Default(true) bool areNotificationsEnabled,
    String? errorMessage,
  }) = _SettingsState;

  const SettingsState._();
}
