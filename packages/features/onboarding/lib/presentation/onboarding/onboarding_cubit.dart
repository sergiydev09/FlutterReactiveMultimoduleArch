import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State for the onboarding cubit.
class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentPage = 0,
    this.totalPages = 3,
  });

  /// The currently visible page index.
  final int currentPage;

  /// Total number of onboarding pages.
  final int totalPages;

  /// Whether the user is on the last page.
  bool get isLastPage => currentPage == totalPages - 1;

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages,
    );
  }

  @override
  List<Object?> get props => [currentPage, totalPages];
}

/// Cubit that tracks the current onboarding page.
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState());

  /// Updates the current page index.
  void setPage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  /// Advances to the next page.
  void nextPage() {
    if (!state.isLastPage) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }
}
