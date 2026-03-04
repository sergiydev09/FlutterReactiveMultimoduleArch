import '../models/card_dto.dart';
import './cards_api_client.dart';

/// Remote data source for card operations.
class RemoteCardDataSource {
  const RemoteCardDataSource({required CardsApiClient apiClient})
      : _apiClient = apiClient;

  final CardsApiClient _apiClient;

  Future<List<CardDto>> getCards() => _apiClient.getCards();

  Future<CardDto> getCardDetail(String id) => _apiClient.getCardDetail(id);

  Future<CardDto> toggleCardStatus(String id) =>
      _apiClient.toggleCardStatus(id);
}
