import 'package:cards/domain/repositories/card_repository.dart';
import 'package:cards/domain/usecases/get_cards_usecase.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cards_event.dart';
part 'cards_state.dart';
part 'generated/cards_bloc.freezed.dart';

/// BLoC for managing the user's banking cards.
class CardsBloc extends Bloc<CardsEvent, CardsState> {
  CardsBloc({
    required GetCardsUseCase getCardsUseCase,
    required CardRepository cardRepository,
  }) : _getCardsUseCase = getCardsUseCase,
       _cardRepository = cardRepository,
       super(const CardsInitial()) {
    on<LoadCards>(_onLoadCards);
    on<ToggleCardStatus>(_onToggleCardStatus);
  }

  final GetCardsUseCase _getCardsUseCase;
  final CardRepository _cardRepository;

  Future<void> _onLoadCards(
    LoadCards event,
    Emitter<CardsState> emit,
  ) async {
    emit(const CardsLoading());

    final result = await _getCardsUseCase(const NoParams());

    result.match(
      (failure) => emit(CardsError(message: failure.message)),
      (cards) => emit(CardsLoaded(cards: cards)),
    );
  }

  Future<void> _onToggleCardStatus(
    ToggleCardStatus event,
    Emitter<CardsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CardsLoaded) return;

    final result = await _cardRepository.toggleCardStatus(event.cardId);

    result.match(
      (failure) => emit(CardsError(message: failure.message)),
      (updatedCard) {
        final updatedCards = currentState.cards.map((card) {
          return card.id == updatedCard.id ? updatedCard : card;
        }).toList();
        emit(CardsLoaded(cards: updatedCards));
      },
    );
  }
}
