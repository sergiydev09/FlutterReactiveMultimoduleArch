part of 'cards_bloc.dart';

@freezed
sealed class CardsEvent with _$CardsEvent {
  const factory CardsEvent.loadCards() = LoadCards;

  const factory CardsEvent.toggleCardStatus({required String cardId}) =
      ToggleCardStatus;
}
