part of 'cards_list_bloc.dart';

enum CardsListStatus { initial, loading, loaded, error }

extension CardsListStatusX on CardsListStatus {
  bool get isInitial => this == CardsListStatus.initial;
  bool get isLoading => this == CardsListStatus.loading;
  bool get isLoaded => this == CardsListStatus.loaded;
  bool get isError => this == CardsListStatus.error;
}

@freezed
abstract class CardsListState with _$CardsListState {
  const factory CardsListState({
    @Default(CardsListStatus.initial) CardsListStatus status,
    @Default([]) List<CardEntity> cards,
    @Default('') String errorMessage,
  }) = _CardsListState;
}
