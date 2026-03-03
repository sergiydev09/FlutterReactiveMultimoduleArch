import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promotions/data/promotions_datasource.dart';

/// Riverpod providers for the promotions library.
abstract final class PromotionProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemotePromotionsDataSource>((ref) {
    throw UnimplementedError('Must be overridden');
  });
}
