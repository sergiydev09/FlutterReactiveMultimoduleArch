part of 'onboarding_bloc.dart';

@freezed
sealed class OnboardingEvent with _$OnboardingEvent {
  const factory OnboardingEvent.pageChanged({required int page}) = PageChanged;

  const factory OnboardingEvent.nextPageRequested() = NextPageRequested;
}
