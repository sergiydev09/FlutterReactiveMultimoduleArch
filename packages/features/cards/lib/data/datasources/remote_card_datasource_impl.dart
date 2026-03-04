import 'package:cards/data/datasources/cards_api_client.dart';
import 'package:cards/data/datasources/remote_card_datasource.dart';
import 'package:cards/data/models/card_dto.dart';

/// Retrofit-based implementation of [RemoteCardDataSource].
class RemoteCardDataSourceImpl implements RemoteCardDataSource {
  const RemoteCardDataSourceImpl({required this.apiClient});

  final CardsApiClient apiClient;

  @override
  Future<List<CardDto>> getCards() => apiClient.getCards();

  @override
  Future<CardDto> getCardDetail(String id) => apiClient.getCardDetail(id);

  @override
  Future<CardDto> toggleCardStatus(String id) =>
      apiClient.toggleCardStatus(id);
}
