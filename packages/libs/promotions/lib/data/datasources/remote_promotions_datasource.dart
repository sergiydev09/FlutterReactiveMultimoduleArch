import 'package:promotions/data/datasources/promotions_api_client.dart';
import 'package:promotions/data/models/promo_banner_dto.dart';

/// Remote data source for fetching promotional content.
class RemotePromotionsDataSource {
  const RemotePromotionsDataSource({required PromotionsApiClient apiClient})
      : _apiClient = apiClient;

  final PromotionsApiClient _apiClient;

  Future<List<PromoBannerDto>> fetchPromotions() =>
      _apiClient.fetchPromotions();
}
