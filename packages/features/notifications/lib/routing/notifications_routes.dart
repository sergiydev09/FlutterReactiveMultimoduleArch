import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/notifications_providers.dart';
import '../presentation/notifications/bloc/notifications_bloc.dart';
import '../presentation/notifications/page/notifications_page.dart';

/// Route paths and route definitions for the notifications feature.
abstract final class NotificationRoutes {
  // -- Route names --
  static const notifications = 'notifications';

  static final routes = FeatureRoutes(
    shellRoutes: [
      GoRoute(
        name: notifications,
        path: '/$notifications',
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
