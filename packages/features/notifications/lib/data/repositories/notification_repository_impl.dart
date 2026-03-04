import 'package:common/error/failures.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/domain/repositories/notification_repository.dart';

/// Concrete implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({required this.remoteDataSource});

  final RemoteNotificationDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications() =>
      safeApiCall(() async =>
          (await remoteDataSource.getNotifications()).map((m) => m.toEntity()).toList());

  @override
  Future<Either<Failure, void>> markAsRead(String id) =>
      safeApiCall(() => remoteDataSource.markAsRead(id));
}
