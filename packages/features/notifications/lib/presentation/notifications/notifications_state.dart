part of 'notifications_bloc.dart';

/// States for the notifications BLoC.
sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading.
final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

/// Notifications are being loaded.
final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

/// Notifications loaded successfully.
final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({required this.notifications});

  /// List of notifications.
  final List<NotificationEntity> notifications;

  /// Number of unread notifications.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications];
}

/// Error loading notifications.
final class NotificationsError extends NotificationsState {
  const NotificationsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
