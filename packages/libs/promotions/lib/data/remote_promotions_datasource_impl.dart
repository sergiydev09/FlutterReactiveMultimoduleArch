import 'package:promotions/data/models/promo_banner_dto.dart';
import 'package:promotions/data/promotions_api_client.dart';
import 'package:promotions/data/promotions_datasource.dart';

/// Retrofit-based implementation of [RemotePromotionsDataSource].
class RemotePromotionsDataSourceImpl implements RemotePromotionsDataSource {
  const RemotePromotionsDataSourceImpl({required this.apiClient});

  final PromotionsApiClient apiClient;

  @override
  Future<List<PromoBannerDto>> fetchPromotions() =>
      apiClient.fetchPromotions();
}
