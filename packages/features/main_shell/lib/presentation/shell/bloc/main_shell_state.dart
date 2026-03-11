part of 'main_shell_bloc.dart';

enum MainShellStatus { loading, ready, error }

extension MainShellStatusX on MainShellStatus {
  bool get isLoading => this == MainShellStatus.loading;
  bool get isReady => this == MainShellStatus.ready;
  bool get isError => this == MainShellStatus.error;
}

@freezed
abstract class MainShellState with _$MainShellState {
  const factory MainShellState({
    @Default(MainShellStatus.loading) MainShellStatus status,
    ShellConfig? config,
    @Default('') String errorMessage,
  }) = _MainShellState;
}
