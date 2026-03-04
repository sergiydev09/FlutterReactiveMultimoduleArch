part of 'global_position_bloc.dart';

@freezed
sealed class GlobalPositionEvent with _$GlobalPositionEvent {
  const factory GlobalPositionEvent.loadGlobalPosition() = LoadGlobalPosition;

  const factory GlobalPositionEvent.refreshGlobalPosition() =
      RefreshGlobalPosition;
}
