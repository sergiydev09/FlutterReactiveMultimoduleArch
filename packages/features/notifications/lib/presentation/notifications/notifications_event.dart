part of 'notifications_bloc.dart';

/// Events for the notifications BLoC.
sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered to load all notifications.
final class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

/// Triggered to mark a specific notification as read.
final class MarkNotificationAsRead extends NotificationsEvent {
  const MarkNotificationAsRead({required this.notificationId});

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}
