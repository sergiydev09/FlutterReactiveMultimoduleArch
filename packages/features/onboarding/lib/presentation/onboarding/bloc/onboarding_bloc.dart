import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';
part 'generated/onboarding_bloc.freezed.dart';

/// BLoC that tracks the current onboarding page.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<PageChanged>(_onPageChanged);
    on<NextPageRequested>(_onNextPage);
  }

  static const int totalPages = 3;

  void _onPageChanged(
    PageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  void _onNextPage(
    NextPageRequested event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.currentPage < totalPages - 1) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }
}
