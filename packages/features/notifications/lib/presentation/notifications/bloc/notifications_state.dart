part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, loaded, error }

@freezed
abstract class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(NotificationsStatus.initial) NotificationsStatus status,
    @Default([]) List<NotificationEntity> notifications,
    @Default('') String errorMessage,
  }) = _NotificationsState;

  const NotificationsState._();

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
