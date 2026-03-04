import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/promotions_api_client.dart';
import '../data/datasources/remote_promotions_datasource.dart';

/// Riverpod providers for the promotions library.
abstract final class PromotionProviders {
  /// Retrofit API client.
  static final apiClient = Provider<PromotionsApiClient>((ref) {
    return PromotionsApiClient(ref.watch(CommonProviders.dio));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource =
      Provider<RemotePromotionsDataSource>((ref) {
    return RemotePromotionsDataSource(
      apiClient: ref.watch(PromotionProviders.apiClient),
    );
  });
}
