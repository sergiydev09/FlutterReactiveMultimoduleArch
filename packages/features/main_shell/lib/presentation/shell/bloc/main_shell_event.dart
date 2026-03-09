part of 'main_shell_bloc.dart';

@freezed
sealed class MainShellEvent with _$MainShellEvent {
  const factory MainShellEvent.started() = ShellStarted;
  const factory MainShellEvent.logoutRequested() = LogoutRequested;
}
