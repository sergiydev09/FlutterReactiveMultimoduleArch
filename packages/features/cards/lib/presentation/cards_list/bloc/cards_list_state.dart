part of 'cards_list_bloc.dart';

@freezed
sealed class CardsListState with _$CardsListState {
  const factory CardsListState.initial() = CardsListInitial;

  const factory CardsListState.loading() = CardsListLoading;

  const factory CardsListState.loaded({required List<CardEntity> cards}) =
      CardsListLoaded;

  const factory CardsListState.error({required String message}) = CardsListError;
}
