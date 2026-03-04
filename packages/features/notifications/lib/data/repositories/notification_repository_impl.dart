import 'package:common/error/failures.dart';
import 'package:dio/dio.dart';
import 'package:domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/domain/repositories/notification_repository.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required this.remoteDataSource});

  final RemoteNotificationDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() async {
    try {
      final models = await remoteDataSource.getNotifications();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al obtener notificaciones',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Error al marcar notificacion como leida',
          statusCode: e.response?.statusCode,
        ),
      );
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
