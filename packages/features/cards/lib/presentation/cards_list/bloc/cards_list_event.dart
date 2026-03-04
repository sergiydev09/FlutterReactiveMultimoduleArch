part of 'cards_list_bloc.dart';

@freezed
sealed class CardsListEvent with _$CardsListEvent {
  const factory CardsListEvent.loadCards() = LoadCards;

  const factory CardsListEvent.toggleCardStatus({required String cardId}) =
      ToggleCardStatus;
}
