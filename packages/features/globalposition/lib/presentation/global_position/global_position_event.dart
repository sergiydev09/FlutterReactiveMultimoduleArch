part of 'global_position_bloc.dart';

/// Events for the global position BLoC.
sealed class GlobalPositionEvent extends Equatable {
  const GlobalPositionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load the global position data.
final class LoadGlobalPosition extends GlobalPositionEvent {
  const LoadGlobalPosition();
}

/// Triggered to refresh the global position data (pull-to-refresh).
final class RefreshGlobalPosition extends GlobalPositionEvent {
  const RefreshGlobalPosition();
}
