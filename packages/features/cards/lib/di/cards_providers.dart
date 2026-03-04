import 'package:cards/data/datasources/cards_api_client.dart';
import 'package:cards/data/datasources/remote_card_datasource.dart';
import 'package:cards/data/repositories/card_repository_impl.dart';
import 'package:cards/domain/repositories/card_repository.dart';
import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod providers for the cards feature.
abstract final class CardProviders {
  /// Retrofit API client.
  static final apiClient = Provider<CardsApiClient>((ref) {
    return CardsApiClient(ref.watch(CommonProviders.dio));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource = Provider<RemoteCardDataSource>((ref) {
    return RemoteCardDataSource(
      apiClient: ref.watch(CardProviders.apiClient),
    );
  });

  /// Repository for card operations.
  static final repository = Provider<CardRepository>((ref) {
    return CardRepositoryImpl(
      remoteDataSource: ref.watch(CardProviders.remoteDataSource),
    );
  });
}
