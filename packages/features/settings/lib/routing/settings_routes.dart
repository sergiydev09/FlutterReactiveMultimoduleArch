import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/security.dart';
import 'package:settings_feature/presentation/settings/settings_bloc.dart';
import 'package:settings_feature/presentation/settings/settings_page.dart';

/// Route paths and route definitions for settings.
abstract final class SettingsRoutes {
  // -- Paths --
  static const settings = '/settings';

  // -- Routes --

  static final routes = FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: settings,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => SettingsBloc(),
            child: SettingsPage(
              onLogout: () {
                container.read(isLoggedInProvider.notifier).set(value: false);
              },
            ),
          );
        },
      ),
    ],
  );
}
