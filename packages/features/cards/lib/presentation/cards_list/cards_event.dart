part of 'cards_bloc.dart';

/// Events for the cards BLoC.
sealed class CardsEvent extends Equatable {
  const CardsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all user's cards.
final class LoadCards extends CardsEvent {
  const LoadCards();
}

/// Triggered to toggle a card's active/blocked status.
final class ToggleCardStatus extends CardsEvent {
  const ToggleCardStatus({required this.cardId});

  final String cardId;

  @override
  List<Object?> get props => [cardId];
}
