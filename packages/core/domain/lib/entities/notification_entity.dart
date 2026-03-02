import 'package:equatable/equatable.dart';

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
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.deepLink,
  });

  /// Unique notification identifier.
  final String id;

  /// Notification headline.
  final String title;

  /// Notification body text.
  final String body;

  /// Notification category.
  final NotificationType type;

  /// Whether the notification has been read.
  final bool isRead;

  /// When the notification was created.
  final DateTime createdAt;

  /// Optional deep link URI for navigation on tap.
  final String? deepLink;

  /// Creates a copy with optionally overridden fields.
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? deepLink,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      deepLink: deepLink ?? this.deepLink,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    isRead,
    createdAt,
    deepLink,
  ];
}
