import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/notification_entity.freezed.dart';

/// Notification type for visual categorization.
enum NotificationType {
  /// Transaction-related notification.
  transaction,

  /// Security alert (login, password change).
  security,

  /// Promotional / marketing.
  promotion,

  /// System or maintenance update.
  system,

  /// General information.
  info,
}

/// Represents an in-app notification.
@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    required DateTime createdAt,
    @Default(false) bool isRead,
    String? deepLink,
  }) = _NotificationEntity;
}
