import 'package:accounts/routing/accounts_routes.dart';
import 'package:authentication/routing/auth_routes.dart';
import 'package:cards/routing/cards_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/routing/globalposition_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:main_shell/main_shell.dart';
import 'package:notifications_feature/routing/notifications_routes.dart';
import 'package:payments/routing/payments_routes.dart';
import 'package:settings/routing/settings_routes.dart';
import '../di/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isSessionActive = ref.watch(SecurityProviders.isSessionActive);
  ref.watch(CommonProviders.localeChangeNotifier);

  return GoRouter(
    initialLocation: AuthRoutes.login,
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == AuthRoutes.login ||
          state.matchedLocation == AuthRoutes.forgotPassword;

      if (!isSessionActive && !isAuthRoute) return AuthRoutes.login;
      if (isSessionActive && isAuthRoute) return GlobalPositionRoutes.home;

      return null;
    },
    routes: [
      ...AuthRoutes.routes.fullScreenRoutes,
      // TODO(onboarding): Descomentar cuando se active el flujo de onboarding.
      // ...OnboardingRoutes.routes.fullScreenRoutes,
      ShellRoute(
        builder: MainShellRoutes.builder,
        routes: [
          ...GlobalPositionRoutes.routes.shellRoutes,
          ...PaymentRoutes.routes.shellRoutes,
          ...NotificationRoutes.routes.shellRoutes,
        ],
      ),
      ...AccountRoutes.routes.fullScreenRoutes,
      ...CardRoutes.routes.fullScreenRoutes,
      ...PaymentRoutes.routes.fullScreenRoutes,
      ...SettingsRoutes.routes.fullScreenRoutes,
    ],
  );
});
