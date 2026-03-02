part of 'settings_bloc.dart';

/// Events for the settings BLoC.
sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle between light and dark theme.
final class ToggleTheme extends SettingsEvent {
  const ToggleTheme();
}

/// Toggle biometric authentication on/off.
final class ToggleBiometrics extends SettingsEvent {
  const ToggleBiometrics();
}

/// Toggle push notifications on/off.
final class ToggleNotifications extends SettingsEvent {
  const ToggleNotifications();
}
