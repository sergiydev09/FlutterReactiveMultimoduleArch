import 'package:domain/entities/notification_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';
part 'generated/notifications_bloc.freezed.dart';

/// BLoC for managing in-app notifications.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository,
       super(const NotificationsState()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  final NotificationRepository _notificationRepository;

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final result = await _notificationRepository.getNotifications();

    result.match(
      (failure) => emit(state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: failure.message,
      )),
      (notifications) => emit(state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
      )),
    );
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state.status != NotificationsStatus.loaded) return;

    final result = await _notificationRepository.markAsRead(
      event.notificationId,
    );

    result.match(
      (failure) {
        // Silently fail - keep current state.
      },
      (_) {
        final updatedNotifications = state.notifications.map((n) {
          return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
        }).toList();
        emit(state.copyWith(notifications: updatedNotifications));
      },
    );
  }
}
