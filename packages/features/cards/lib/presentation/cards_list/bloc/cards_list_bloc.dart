import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/usecases/get_cards_usecase.dart';
import '../../../domain/usecases/toggle_card_status_usecase.dart';

part 'cards_list_event.dart';
part 'cards_list_state.dart';
part 'generated/cards_list_bloc.freezed.dart';

/// BLoC for managing the user's banking cards.
class CardsListBloc extends Bloc<CardsListEvent, CardsListState> {
  CardsListBloc({
    required GetCardsUseCase getCardsUseCase,
    required ToggleCardStatusUseCase toggleCardStatusUseCase,
  }) : _getCardsUseCase = getCardsUseCase,
       _toggleCardStatusUseCase = toggleCardStatusUseCase,
       super(const CardsListState()) {
    on<LoadCards>(_onLoadCards);
    on<ToggleCardStatus>(_onToggleCardStatus);
  }

  final GetCardsUseCase _getCardsUseCase;
  final ToggleCardStatusUseCase _toggleCardStatusUseCase;

  Future<void> _onLoadCards(
    LoadCards event,
    Emitter<CardsListState> emit,
  ) async {
    emit(state.copyWith(status: CardsListStatus.loading));

    final result = await _getCardsUseCase(const NoParams());

    result.match(
      (failure) => emit(state.copyWith(
        status: CardsListStatus.error,
        errorMessage: failure.message,
      )),
      (cards) => emit(state.copyWith(
        status: CardsListStatus.loaded,
        cards: cards,
      )),
    );
  }

  Future<void> _onToggleCardStatus(
    ToggleCardStatus event,
    Emitter<CardsListState> emit,
  ) async {
    if (state.status != CardsListStatus.loaded) return;

    final result = await _toggleCardStatusUseCase(event.cardId);

    result.match(
      (failure) => emit(state.copyWith(
        status: CardsListStatus.error,
        errorMessage: failure.message,
      )),
      (updatedCard) {
        final updatedCards = state.cards.map((card) {
          return card.id == updatedCard.id ? updatedCard : card;
        }).toList();
        emit(state.copyWith(cards: updatedCards));
      },
    );
  }
}
