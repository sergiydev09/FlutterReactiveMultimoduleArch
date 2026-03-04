import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/remote_card_datasource.dart';

/// Concrete implementation of [CardRepository].
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl({required this.remoteDataSource});

  final RemoteCardDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<CardEntity>>> getCards() =>
      safeApiCall(() async =>
          (await remoteDataSource.getCards()).map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, CardEntity>> getCardDetail(String id) =>
      safeApiCall(() async => (await remoteDataSource.getCardDetail(id)).toEntity());

  @override
  Future<Either<Failure, CardEntity>> toggleCardStatus(String id) =>
      safeApiCall(() async => (await remoteDataSource.toggleCardStatus(id)).toEntity());
}
