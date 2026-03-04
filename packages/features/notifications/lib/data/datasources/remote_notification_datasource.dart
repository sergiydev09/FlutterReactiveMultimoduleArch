import 'package:notifications_feature/data/datasources/notifications_api_client.dart';
import 'package:notifications_feature/data/models/notification_dto.dart';

/// Remote data source for notification operations.
class RemoteNotificationDataSource {
  const RemoteNotificationDataSource(
      {required NotificationsApiClient apiClient})
      : _apiClient = apiClient;

  final NotificationsApiClient _apiClient;

  Future<List<NotificationDto>> getNotifications() =>
      _apiClient.getNotifications();

  Future<void> markAsRead(String id) => _apiClient.markAsRead(id);
}
