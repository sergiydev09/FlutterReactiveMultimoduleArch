import 'package:notifications_feature/data/datasources/notifications_api_client.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/data/models/notification_dto.dart';

/// Retrofit-based implementation of [RemoteNotificationDataSource].
class RemoteNotificationDataSourceImpl implements RemoteNotificationDataSource {
  const RemoteNotificationDataSourceImpl({required this.apiClient});

  final NotificationsApiClient apiClient;

  @override
  Future<List<NotificationDto>> getNotifications() =>
      apiClient.getNotifications();

  @override
  Future<void> markAsRead(String id) => apiClient.markAsRead(id);
}
