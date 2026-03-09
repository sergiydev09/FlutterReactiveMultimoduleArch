part of 'main_shell_bloc.dart';

@freezed
sealed class MainShellState with _$MainShellState {
  const factory MainShellState.loading() = ShellLoading;
  const factory MainShellState.ready({
    required ShellConfig config,
  }) = ShellReady;
  const factory MainShellState.error({required String message}) = ShellError;
}
