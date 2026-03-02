import 'package:domain/entities/card_entity.dart';

/// Remote data source contract for card operations.
abstract class RemoteCardDataSource {
  /// Fetches all cards.
  Future<List<CardEntity>> getCards();

  /// Fetches detail of a card by [id].
  Future<CardEntity> getCardDetail(String id);

  /// Toggles the status of a card by [id].
  /// Returns the updated card.
  Future<CardEntity> toggleCardStatus(String id);
}
