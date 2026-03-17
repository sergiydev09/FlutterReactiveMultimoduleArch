import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/notification_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/usecases/get_notifications_usecase.dart';
import '../../../domain/usecases/mark_notification_as_read_usecase.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';
part 'generated/notifications_bloc.freezed.dart';

/// BLoC for managing in-app notifications.
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
       super(const NotificationsState()) {
    on<LoadNotifications>(_onLoad);
    on<MarkNotificationAsRead>(_onMarkAsRead);
  }

  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;

  Future<void> _onLoad(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(state.copyWith(status: NotificationsStatus.loading));

    final result = await _getNotificationsUseCase(const NoParams());

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

    final result =
        await _markNotificationAsReadUseCase(event.notificationId);

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
