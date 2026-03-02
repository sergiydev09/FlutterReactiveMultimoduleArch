import 'package:domain/entities/notification_entity.dart';

/// Remote data source contract for notification operations.
abstract class RemoteNotificationDataSource {
  /// Fetches all notifications.
  Future<List<NotificationEntity>> getNotifications();

  /// Marks the notification with the given [id] as read.
  Future<void> markAsRead(String id);
}
