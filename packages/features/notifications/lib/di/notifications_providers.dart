import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/notifications_api_client.dart';
import '../data/datasources/remote_notification_datasource.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/mark_notification_as_read_usecase.dart';

/// Riverpod providers for the notifications feature.
abstract final class NotificationProviders {
  /// Retrofit API client.
  static final apiClient = Provider<NotificationsApiClient>((ref) {
    return NotificationsApiClient(ref.watch(CommonProviders.dio));
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

  /// Use case to fetch all notifications.
  static final getNotificationsUseCase =
      Provider<GetNotificationsUseCase>((ref) {
    return GetNotificationsUseCase(
      repository: ref.watch(NotificationProviders.repository),
    );
  });

  /// Use case to mark a notification as read.
  static final markNotificationAsReadUseCase =
      Provider<MarkNotificationAsReadUseCase>((ref) {
    return MarkNotificationAsReadUseCase(
      repository: ref.watch(NotificationProviders.repository),
    );
  });
}
