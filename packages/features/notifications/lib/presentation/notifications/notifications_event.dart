part of 'notifications_bloc.dart';

@freezed
sealed class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.loadNotifications() = LoadNotifications;

  const factory NotificationsEvent.markNotificationAsRead({
    required String notificationId,
  }) = MarkNotificationAsRead;
}
