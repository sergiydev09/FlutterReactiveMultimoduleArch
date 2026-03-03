import 'package:go_router/go_router.dart';

/// Defines the routes exposed by a feature module.
///
/// Each feature returns an instance of [FeatureRoutes] from its routing
/// entry-point. The app-level router composes them into a single [GoRouter].
///
/// - [shellRoutes] are displayed inside the main shell (bottom navigation).
/// - [fullScreenRoutes] are displayed without the shell.
class FeatureRoutes {
  const FeatureRoutes({
    this.shellRoutes = const [],
    this.fullScreenRoutes = const [],
  });

  /// Routes rendered inside the [ShellRoute] with bottom navigation.
  final List<RouteBase> shellRoutes;

  /// Routes rendered full-screen, outside the shell.
  final List<RouteBase> fullScreenRoutes;
}
