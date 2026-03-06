import 'package:accounts/routing/accounts_routes.dart';
import 'package:authentication/routing/auth_routes.dart';
import 'package:cards/routing/cards_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/routing/globalposition_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications_feature/routing/notifications_routes.dart';
import 'package:onboarding/routing/onboarding_routes.dart';
import 'package:payments/routing/payments_routes.dart';
import 'package:settings/routing/settings_routes.dart';
import '../di/providers.dart';
import './main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(SecurityProviders.isLoggedIn);
  final hasSeenOnboarding = ref.watch(SecurityProviders.hasSeenOnboarding);
  ref.watch(CommonProviders.localeChangeNotifier);

  return GoRouter(
    initialLocation: AuthRoutes.login,
    redirect: (context, state) {
      final loggingIn =
          state.matchedLocation == AuthRoutes.login ||
          state.matchedLocation == AuthRoutes.forgotPassword;

      if (!isLoggedIn && !loggingIn) return AuthRoutes.login;

      if (isLoggedIn &&
          !hasSeenOnboarding &&
          state.matchedLocation != OnboardingRoutes.onboarding) {
        return OnboardingRoutes.onboarding;
      }

      if (isLoggedIn &&
          hasSeenOnboarding &&
          state.matchedLocation == OnboardingRoutes.onboarding) {
        return GlobalPositionRoutes.home;
      }

      if (isLoggedIn && loggingIn) return GlobalPositionRoutes.home;

      return null;
    },
    routes: [
      ...AuthRoutes.routes.fullScreenRoutes,
      ...OnboardingRoutes.routes.fullScreenRoutes,
      ShellRoute(
        builder: (context, state, child) {
          final container = ProviderScope.containerOf(context);
          return MainShell(
            userName: container.read(SecurityProviders.currentUserName),
            onLogout: () {
              container
                  .read(SecurityProviders.isLoggedIn.notifier)
                  .set(value: false);
            },
            child: child,
          );
        },
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
