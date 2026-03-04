import '../models/notification_dto.dart';
import './notifications_api_client.dart';

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
