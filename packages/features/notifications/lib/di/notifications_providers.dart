import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications_feature/data/datasources/notifications_api_client.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/data/repositories/notification_repository_impl.dart';
import 'package:notifications_feature/domain/repositories/notification_repository.dart';

/// Riverpod providers for the notifications feature.
abstract final class NotificationProviders {
  /// Retrofit API client.
  static final apiClient = Provider<NotificationsApiClient>((ref) {
    return NotificationsApiClient(ref.watch(dioProvider));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource =
      Provider<RemoteNotificationDataSource>((ref) {
    return RemoteNotificationDataSource(
      apiClient: ref.watch(NotificationProviders.apiClient),
    );
  });

  /// Repository for notification operations.
  static final repository = Provider<NotificationRepository>((ref) {
    return NotificationRepositoryImpl(
      remoteDataSource: ref.watch(NotificationProviders.remoteDataSource),
    );
  });
}
