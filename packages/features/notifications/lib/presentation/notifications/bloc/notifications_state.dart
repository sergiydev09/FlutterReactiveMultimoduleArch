part of 'notifications_bloc.dart';

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState.initial() = NotificationsInitial;

  const factory NotificationsState.loading() = NotificationsLoading;

  const factory NotificationsState.loaded({
    required List<NotificationEntity> notifications,
  }) = NotificationsLoaded;

  const factory NotificationsState.error({required String message}) =
      NotificationsError;
}

extension NotificationsLoadedX on NotificationsLoaded {
  int get unreadCount => notifications.where((n) => !n.isRead).length;
}
