import 'package:promotions/domain/promo_banner.dart';

/// Remote data source contract for fetching promotional content.
abstract class RemotePromotionsDataSource {
  /// Fetches the list of active promotional banners.
  Future<List<PromoBanner>> fetchPromotions();
}
