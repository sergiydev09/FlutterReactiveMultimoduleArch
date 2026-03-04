import 'package:promotions/data/models/promo_banner_dto.dart';

/// Remote data source contract for fetching promotional content.
abstract class RemotePromotionsDataSource {
  /// Fetches the list of active promotional banners.
  Future<List<PromoBannerDto>> fetchPromotions();
}
