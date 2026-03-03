import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/data/repositories/notification_repository_impl.dart';
import 'package:notifications_feature/domain/repositories/notification_repository.dart';

/// Riverpod providers for the notifications feature.
abstract final class NotificationProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemoteNotificationDataSource>((ref) {
    throw UnimplementedError('Must be overridden');
  });

  /// Repository for notification operations.
  static final repository = Provider<NotificationRepository>((ref) {
    return NotificationRepositoryImpl(
      remoteDataSource: ref.watch(NotificationProviders.remoteDataSource),
    );
  });
}
