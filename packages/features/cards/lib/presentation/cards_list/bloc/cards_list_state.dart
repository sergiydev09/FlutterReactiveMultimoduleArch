part of 'cards_list_bloc.dart';

enum CardsListStatus { initial, loading, loaded, error }

@freezed
abstract class CardsListState with _$CardsListState {
  const factory CardsListState({
    @Default(CardsListStatus.initial) CardsListStatus status,
    @Default([]) List<CardEntity> cards,
    @Default('') String errorMessage,
  }) = _CardsListState;
}
