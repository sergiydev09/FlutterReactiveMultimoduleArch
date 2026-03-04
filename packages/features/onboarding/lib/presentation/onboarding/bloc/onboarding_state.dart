part of 'onboarding_bloc.dart';

@freezed
sealed class OnboardingState with _$OnboardingState {
  const factory OnboardingState.idle({required int currentPage}) =
      OnboardingIdle;
}

extension OnboardingIdleX on OnboardingIdle {
  bool get isLastPage => currentPage == OnboardingBloc.totalPages - 1;
}
