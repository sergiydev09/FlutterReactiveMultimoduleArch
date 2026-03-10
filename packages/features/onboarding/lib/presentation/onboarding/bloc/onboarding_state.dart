part of 'onboarding_bloc.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(0) int currentPage,
  }) = _OnboardingState;

  const OnboardingState._();

  bool get isLastPage => currentPage == OnboardingBloc.totalPages - 1;
}
