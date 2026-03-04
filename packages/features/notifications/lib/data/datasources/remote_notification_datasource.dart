import 'package:notifications_feature/data/models/notification_dto.dart';

/// Remote data source contract for notification operations.
abstract class RemoteNotificationDataSource {
  /// Fetches all notifications.
  Future<List<NotificationDto>> getNotifications();

  /// Marks the notification with the given [id] as read.
  Future<void> markAsRead(String id);
}
