import 'package:accounts/routing/accounts_routes.dart';
import 'package:authentication/routing/auth_routes.dart';
import 'package:cards/routing/cards_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/routing/globalposition_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/di/providers.dart';
import 'package:mobile_app/routing/main_shell.dart';
import 'package:notifications_feature/routing/notifications_routes.dart';
import 'package:onboarding/routing/onboarding_routes.dart';
import 'package:payments/routing/payments_routes.dart';
import 'package:settings_feature/routing/settings_routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

  final auth = authRoutes(
    environmentProvider: environmentProvider,
    onLoginSuccess: (user) {
      ref.read(isLoggedInProvider.notifier).set(value: true);
      ref.read(currentUserNameProvider.notifier).set(user.fullName);
    },
    onEnvironmentChanged: (env) {
      ref.read(environmentProvider.notifier).set(env);
    },
    showEnvironmentSelector: true,
  );
  final onboarding = onboardingRoutes(
    onComplete: () {
      ref.read(hasSeenOnboardingProvider.notifier).set(value: true);
    },
    redirectTo: GlobalPositionPaths.home,
  );
  final gp = globalPositionRoutes();
  final payment = paymentRoutes();
  final notification = notificationRoutes();
  final account = accountRoutes();
  final card = cardRoutes();
  final settings = settingsRoutes(
    onLogout: () {
      ref.read(isLoggedInProvider.notifier).set(value: false);
    },
  );

  return GoRouter(
    initialLocation: AuthPaths.login,
    redirect: (context, state) {
      final loggingIn =
          state.matchedLocation == AuthPaths.login ||
          state.matchedLocation == AuthPaths.forgotPassword;

      if (!isLoggedIn && !loggingIn) return AuthPaths.login;

      if (isLoggedIn &&
          !hasSeenOnboarding &&
          state.matchedLocation != OnboardingPaths.onboarding) {
        return OnboardingPaths.onboarding;
      }

      if (isLoggedIn && loggingIn) return GlobalPositionPaths.home;

      return null;
    },
    routes: [
      ...auth.fullScreenRoutes,
      ...onboarding.fullScreenRoutes,
      ShellRoute(
        builder: (context, state, child) {
          final container = ProviderScope.containerOf(context);
          final userName = container.read(currentUserNameProvider);
          return MainShell(
            userName: userName,
            onLogout: () {
              container.read(isLoggedInProvider.notifier).set(value: false);
            },
            child: child,
          );
        },
        routes: [
          ...gp.shellRoutes,
          ...payment.shellRoutes,
          ...notification.shellRoutes,
        ],
      ),
      ...account.fullScreenRoutes,
      ...card.fullScreenRoutes,
      ...payment.fullScreenRoutes,
      ...settings.fullScreenRoutes,
    ],
  );
});
