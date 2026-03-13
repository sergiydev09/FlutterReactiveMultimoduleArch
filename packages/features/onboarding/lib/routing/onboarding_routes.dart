import 'dart:async';

import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/onboarding_providers.dart';
import '../presentation/onboarding/bloc/onboarding_bloc.dart';
import '../presentation/onboarding/page/onboarding_page.dart';

/// Route paths and route definitions for onboarding.
abstract final class OnboardingRoutes {
  // -- Route names --
  static const onboarding = 'onboarding';

  static final routes = FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        name: onboarding,
        path: '/$onboarding',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => OnboardingBloc(),
            child: OnboardingPage(
              onComplete: () {
                unawaited(
                  container
                      .read(OnboardingProviders.hasSeenOnboarding.notifier)
                      .markSeen(),
                );
              },
            ),
          );
        },
      ),
    ],
  );
}
