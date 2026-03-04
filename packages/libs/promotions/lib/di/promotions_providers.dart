import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promotions/data/promotions_api_client.dart';
import 'package:promotions/data/promotions_datasource.dart';
import 'package:promotions/data/remote_promotions_datasource_impl.dart';

/// Riverpod providers for the promotions library.
abstract final class PromotionProviders {
  /// Retrofit API client.
  static final apiClient = Provider<PromotionsApiClient>((ref) {
    return PromotionsApiClient(ref.watch(dioProvider));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource =
      Provider<RemotePromotionsDataSource>((ref) {
    return RemotePromotionsDataSourceImpl(
      apiClient: ref.watch(PromotionProviders.apiClient),
    );
  });
}
