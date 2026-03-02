import 'package:domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notifications_feature/domain/repositories/notification_repository.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

/// BLoC for managing in-app notifications.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required NotificationRepository notificationRepository,
  }) : _notificationRepository = notificationRepository,
       super(const NotificationsInitial()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  final NotificationRepository _notificationRepository;

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());

    final result = await _notificationRepository.getNotifications();

    result.match(
      (failure) => emit(NotificationsError(message: failure.message)),
      (notifications) => emit(
        NotificationsLoaded(notifications: notifications),
      ),
    );
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotificationsLoaded) return;

    final result = await _notificationRepository.markAsRead(
      event.notificationId,
    );

    result.match(
      (failure) {
        // Silently fail - keep current state.
      },
      (_) {
        final updatedNotifications = currentState.notifications.map((n) {
          return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
        }).toList();
        emit(NotificationsLoaded(notifications: updatedNotifications));
      },
    );
  }
}
