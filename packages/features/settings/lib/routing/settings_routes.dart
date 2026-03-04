import 'dart:async';
import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/security.dart';
import '../presentation/settings/bloc/settings_bloc.dart';
import '../presentation/settings/page/settings_page.dart';

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
          final initialBiometricEnabled =
              container.read(SecurityProviders.biometricEnabled).value ?? false;

          return BlocProvider(
            create: (_) => SettingsBloc(
              initialBiometricEnabled: initialBiometricEnabled,
              onBiometricToggle: () {
                unawaited(
                  container
                      .read(SecurityProviders.biometricEnabled.notifier)
                      .toggle(),
                );
              },
            ),
            child: SettingsPage(
              onLogout: () {
                container
                    .read(SecurityProviders.isLoggedIn.notifier)
                    .set(value: false);
              },
            ),
          );
        },
      ),
    ],
  );
}
