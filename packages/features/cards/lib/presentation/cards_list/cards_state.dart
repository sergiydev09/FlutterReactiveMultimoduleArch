part of 'cards_bloc.dart';

/// States for the cards BLoC.
sealed class CardsState extends Equatable {
  const CardsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
final class CardsInitial extends CardsState {
  const CardsInitial();
}

/// Cards are being loaded.
final class CardsLoading extends CardsState {
  const CardsLoading();
}

/// Cards loaded successfully.
final class CardsLoaded extends CardsState {
  const CardsLoaded({required this.cards});

  /// List of user's cards.
  final List<CardEntity> cards;

  @override
  List<Object?> get props => [cards];
}

/// Error loading cards.
final class CardsError extends CardsState {
  const CardsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
