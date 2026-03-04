import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/repositories/card_repository.dart';
import '../../../domain/usecases/get_cards_usecase.dart';

part 'cards_list_event.dart';
part 'cards_list_state.dart';
part 'generated/cards_list_bloc.freezed.dart';

/// BLoC for managing the user's banking cards.
class CardsListBloc extends Bloc<CardsListEvent, CardsListState> {
  CardsListBloc({
    required GetCardsUseCase getCardsUseCase,
    required CardRepository cardRepository,
  }) : _getCardsUseCase = getCardsUseCase,
       _cardRepository = cardRepository,
       super(const CardsListInitial()) {
    on<LoadCards>(_onLoadCards);
    on<ToggleCardStatus>(_onToggleCardStatus);
  }

  final GetCardsUseCase _getCardsUseCase;
  final CardRepository _cardRepository;

  Future<void> _onLoadCards(
    LoadCards event,
    Emitter<CardsListState> emit,
  ) async {
    emit(const CardsListLoading());

    final result = await _getCardsUseCase(const NoParams());

    result.match(
      (failure) => emit(CardsListError(message: failure.message)),
      (cards) => emit(CardsListLoaded(cards: cards)),
    );
  }

  Future<void> _onToggleCardStatus(
    ToggleCardStatus event,
    Emitter<CardsListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CardsListLoaded) return;

    final result = await _cardRepository.toggleCardStatus(event.cardId);

    result.match(
      (failure) => emit(CardsListError(message: failure.message)),
      (updatedCard) {
        final updatedCards = currentState.cards.map((card) {
          return card.id == updatedCard.id ? updatedCard : card;
        }).toList();
        emit(CardsListLoaded(cards: updatedCards));
      },
    );
  }
}
