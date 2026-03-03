import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications_feature/di/notifications_providers.dart';
import 'package:notifications_feature/presentation/notifications/notifications_bloc.dart';
import 'package:notifications_feature/presentation/notifications/notifications_page.dart';

/// Route path constants for the notifications feature.
abstract final class NotificationPaths {
  static const notifications = '/notifications';
}

/// Builds the notifications feature routes.
FeatureRoutes notificationRoutes() {
  return FeatureRoutes(
    shellRoutes: [
      GoRoute(
        path: NotificationPaths.notifications,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          final notifRepo = container.read(NotificationProviders.repository);
          return BlocProvider(
            create: (_) => NotificationsBloc(
              notificationRepository: notifRepo,
            )..add(const LoadNotifications()),
            child: const NotificationsPage(),
          );
        },
      ),
    ],
  );
}
