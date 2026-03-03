import 'package:common/routing/feature_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onboarding/presentation/onboarding/onboarding_bloc.dart';
import 'package:onboarding/presentation/onboarding/onboarding_page.dart';

/// Route path constants for the onboarding feature.
abstract final class OnboardingPaths {
  static const onboarding = '/onboarding';
}

/// Builds the onboarding feature routes.
///
/// [onComplete] is called when the user finishes the onboarding flow.
/// [redirectTo] is the path to navigate to after onboarding completes.
FeatureRoutes onboardingRoutes({
  required VoidCallback onComplete,
  required String redirectTo,
}) {
  return FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: OnboardingPaths.onboarding,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => OnboardingBloc(),
            child: OnboardingPage(
              onComplete: () {
                onComplete();
                context.go(redirectTo);
              },
            ),
          );
        },
      ),
    ],
  );
}
