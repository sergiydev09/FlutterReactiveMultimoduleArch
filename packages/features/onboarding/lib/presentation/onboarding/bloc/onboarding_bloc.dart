import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';
part 'generated/onboarding_bloc.freezed.dart';

/// BLoC that tracks the current onboarding page.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingIdle(currentPage: 0)) {
    on<PageChanged>(_onPageChanged);
    on<NextPageRequested>(_onNextPage);
  }

  static const int totalPages = 3;

  void _onPageChanged(
    PageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingIdle(currentPage: event.page));
  }

  void _onNextPage(
    NextPageRequested event,
    Emitter<OnboardingState> emit,
  ) {
    final current = switch (state) {
      OnboardingIdle(:final currentPage) => currentPage,
    };

    if (current < totalPages - 1) {
      emit(OnboardingIdle(currentPage: current + 1));
    }
  }
}
