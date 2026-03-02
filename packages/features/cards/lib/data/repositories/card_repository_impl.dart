import 'package:cards/data/datasources/remote_card_datasource.dart';
import 'package:cards/domain/repositories/card_repository.dart';
import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Concrete implementation of [CardRepository].
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl({required this.remoteDataSource});

  final RemoteCardDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<CardEntity>>> getCards() async {
    try {
      final cards = await remoteDataSource.getCards();
      return Right(cards);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al obtener tarjetas',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> getCardDetail(String id) async {
    try {
      final card = await remoteDataSource.getCardDetail(id);
      return Right(card);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al obtener detalle de tarjeta',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CardEntity>> toggleCardStatus(String id) async {
    try {
      final card = await remoteDataSource.toggleCardStatus(id);
      return Right(card);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al cambiar estado de tarjeta',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
