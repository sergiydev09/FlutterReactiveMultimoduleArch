import 'package:cards/data/models/card_dto.dart';

/// Remote data source contract for card operations.
abstract class RemoteCardDataSource {
  /// Fetches all cards.
  Future<List<CardDto>> getCards();

  /// Fetches detail of a card by [id].
  Future<CardDto> getCardDetail(String id);

  /// Toggles the status of a card by [id].
  /// Returns the updated card.
  Future<CardDto> toggleCardStatus(String id);
}
