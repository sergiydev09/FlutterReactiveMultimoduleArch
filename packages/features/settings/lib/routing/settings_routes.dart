import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/security.dart';
import '../di/settings_providers.dart';
import '../presentation/settings/bloc/settings_bloc.dart';
import '../presentation/settings/page/settings_page.dart';

/// Route paths and route definitions for settings.
abstract final class SettingsRoutes {
  // -- Route names --
  static const settings = 'settings';

  // -- Routes --

  static final routes = FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        name: settings,
        path: '/$settings',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);

          return BlocProvider(
            create: (_) => SettingsBloc(
              getBiometricsStatusUseCase:
                  container.read(SettingsProviders.getBiometricsStatusUseCase),
              toggleBiometricsUseCase:
                  container.read(SettingsProviders.toggleBiometricsUseCase),
              logoutUseCase: container.read(SecurityProviders.logoutUseCase),
            )..add(const SettingsStarted()),
            child: const SettingsPage(),
          );
        },
      ),
    ],
  );
}
