part of 'main_shell_bloc.dart';

enum MainShellStatus { loading, ready, error }

@freezed
abstract class MainShellState with _$MainShellState {
  const factory MainShellState({
    @Default(MainShellStatus.loading) MainShellStatus status,
    ShellConfig? config,
    @Default('') String errorMessage,
  }) = _MainShellState;
}
