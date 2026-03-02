part of 'settings_bloc.dart';

/// State for the settings BLoC.
class SettingsState extends Equatable {
  const SettingsState({
    required this.isDarkMode,
    required this.isBiometricsEnabled,
    required this.areNotificationsEnabled,
  });

  /// Whether the dark theme is enabled.
  final bool isDarkMode;

  /// Whether biometric authentication is enabled.
  final bool isBiometricsEnabled;

  /// Whether push notifications are enabled.
  final bool areNotificationsEnabled;

  /// Creates a copy with optionally overridden fields.
  SettingsState copyWith({
    bool? isDarkMode,
    bool? isBiometricsEnabled,
    bool? areNotificationsEnabled,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
      areNotificationsEnabled:
          areNotificationsEnabled ?? this.areNotificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        isDarkMode,
        isBiometricsEnabled,
        areNotificationsEnabled,
      ];
}
