part of 'notifications_bloc.dart';

enum NotificationsStatus { initial, loading, loaded, error }

extension NotificationsStatusX on NotificationsStatus {
  bool get isInitial => this == NotificationsStatus.initial;
  bool get isLoading => this == NotificationsStatus.loading;
  bool get isLoaded => this == NotificationsStatus.loaded;
  bool get isError => this == NotificationsStatus.error;
}

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
