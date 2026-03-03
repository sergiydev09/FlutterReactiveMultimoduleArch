import 'package:common/routing/feature_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_feature/presentation/settings/settings_bloc.dart';
import 'package:settings_feature/presentation/settings/settings_page.dart';

/// Route path constants for the settings feature.
abstract final class SettingsPaths {
  static const settings = '/settings';
}

/// Builds the settings feature routes.
///
/// [onLogout] is called when the user logs out from settings.
FeatureRoutes settingsRoutes({required VoidCallback onLogout}) {
  return FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: SettingsPaths.settings,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => SettingsBloc(),
            child: SettingsPage(onLogout: onLogout),
          );
        },
      ),
    ],
  );
}
