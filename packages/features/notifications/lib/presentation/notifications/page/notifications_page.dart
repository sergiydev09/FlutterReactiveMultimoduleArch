import 'package:common/utils/formatters.dart';
import 'package:domain/entities/notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';
import '../bloc/notifications_bloc.dart';

/// Page showing the list of in-app notifications.
///
/// Does NOT include its own Scaffold/AppBar – designed to be hosted
/// inside a shell that provides the app bar, drawer, and bottom nav.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
    this.onNotificationTap,
  });

  /// Callback when a notification is tapped.
  final void Function(NotificationEntity notification)? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        return switch (state) {
          NotificationsInitial() || NotificationsLoading() => const Center(
            child: CircularProgressIndicator(
              color: BankingColors.primary,
            ),
          ),
          NotificationsError(:final message) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: BankingColors.error,
                ),
                const SizedBox(height: 16),
                Text(message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationsBloc>().add(
                      const LoadNotifications(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BankingColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          NotificationsLoaded(:final notifications) =>
            notifications.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: BankingColors.onBackgroundLightSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No tienes notificaciones',
                          style: TextStyle(
                            fontSize: 16,
                            color: BankingColors.onBackgroundLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => const Divider(
                      height: 1,
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationsBloc>().add(
                              MarkNotificationAsRead(
                                notificationId: notification.id,
                              ),
                            );
                          }
                          onNotificationTap?.call(notification);
                        },
                      );
                    },
                  ),
        };
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: notification.isRead
          ? null
          : BankingColors.primary.withValues(alpha: 0.04),
      leading: CircleAvatar(
        backgroundColor: _iconColor.withValues(alpha: 0.1),
        child: Icon(
          _iconData,
          color: _iconColor,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
          color: BankingColors.onBackgroundLight,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            notification.body,
            style: const TextStyle(
              fontSize: 13,
              color: BankingColors.onBackgroundLightSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatRelativeTime(notification.createdAt),
            style: const TextStyle(
              fontSize: 11,
              color: BankingColors.onBackgroundLightSecondary,
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: BankingColors.primary,
                shape: BoxShape.circle,
              ),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  IconData get _iconData {
    return switch (notification.type) {
      NotificationType.transaction => Icons.receipt_long_outlined,
      NotificationType.security => Icons.shield_outlined,
      NotificationType.promotion => Icons.local_offer_outlined,
      NotificationType.system => Icons.info_outline,
      NotificationType.info => Icons.info_outline,
    };
  }

  Color get _iconColor {
    return switch (notification.type) {
      NotificationType.transaction => BankingColors.primary,
      NotificationType.security => BankingColors.error,
      NotificationType.promotion => BankingColors.accent,
      NotificationType.system => BankingColors.info,
      NotificationType.info => BankingColors.info,
    };
  }
}
