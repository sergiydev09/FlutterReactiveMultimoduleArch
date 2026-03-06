import 'dart:async';
import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';
import '../bloc/onboarding_bloc.dart';

/// The onboarding page shown to first-time users.
///
/// Contains 3 slides introducing the app's main features,
/// with Next/Skip navigation and a Done button on the final slide.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.onComplete,
  });

  /// Callback when onboarding is complete.
  final VoidCallback? onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  List<_SlideData> _buildSlides() => [
        _SlideData(
          icon: Icons.account_balance,
          title: LocaleKeys.onboarding_slide1_title.tr(),
          description: LocaleKeys.onboarding_slide1_description.tr(),
          color: BankingColors.primary,
        ),
        _SlideData(
          icon: Icons.dashboard_outlined,
          title: LocaleKeys.onboarding_slide2_title.tr(),
          description: LocaleKeys.onboarding_slide2_description.tr(),
          color: BankingColors.primaryLight,
        ),
        _SlideData(
          icon: Icons.security_outlined,
          title: LocaleKeys.onboarding_slide3_title.tr(),
          description: LocaleKeys.onboarding_slide3_description.tr(),
          color: BankingColors.secondary,
        ),
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context) {
    final bloc = context.read<OnboardingBloc>();
    final isLastPage = switch (bloc.state) {
      OnboardingIdle(:final isLastPage) => isLastPage,
    };

    if (isLastPage) {
      widget.onComplete?.call();
    } else {
      bloc.add(const NextPageRequested());
    }
  }

  void _onSkip() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _buildSlides();

    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingIdle) {
              unawaited(
                _pageController.animateToPage(
                  state.currentPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              );
            }
          },
          builder: (context, state) {
            final currentPage = switch (state) {
              OnboardingIdle(:final currentPage) => currentPage,
            };
            final isLastPage = switch (state) {
              OnboardingIdle(:final isLastPage) => isLastPage,
            };

            return Column(
              children: [
                // Skip button.
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: isLastPage ? null : _onSkip,
                      child: Text(
                        isLastPage ? '' : LocaleKeys.onboarding_skip.tr(),
                        style: const TextStyle(
                          color: BankingColors.onBackgroundLightSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                // Pages.
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (index) {
                      context.read<OnboardingBloc>().add(
                        PageChanged(page: index),
                      );
                    },
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return _OnboardingSlide(data: slide);
                    },
                  ),
                ),
                // Page indicators.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slides.length, (index) {
                      final isActive = index == currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? BankingColors.primary
                              : BankingColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
                // Next / Get started button.
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _onNext(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BankingColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        isLastPage
                            ? LocaleKeys.onboarding_start.tr()
                            : LocaleKeys.onboarding_next.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.data});

  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 56,
              color: data.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: BankingColors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: BankingColors.onBackgroundLightSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
