import 'package:common/error/failures.dart';
import 'package:domain/entities/notification_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Repository contract for notification operations.
abstract class NotificationRepository {
  /// Fetches all notifications for the current user.
  Future<Either<Failure, List<NotificationEntity>>> getNotifications();

  /// Marks the notification with the given [id] as read.
  Future<Either<Failure, void>> markAsRead(String id);
}
