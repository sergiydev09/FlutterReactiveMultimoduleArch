import 'package:cards/data/datasources/remote_card_datasource.dart';
import 'package:cards/data/repositories/card_repository_impl.dart';
import 'package:cards/domain/repositories/card_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod providers for the cards feature.
abstract final class CardProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemoteCardDataSource>((ref) {
    throw UnimplementedError('Must be overridden');
  });

  /// Repository for card operations.
  static final repository = Provider<CardRepository>((ref) {
    return CardRepositoryImpl(
      remoteDataSource: ref.watch(CardProviders.remoteDataSource),
    );
  });
}
