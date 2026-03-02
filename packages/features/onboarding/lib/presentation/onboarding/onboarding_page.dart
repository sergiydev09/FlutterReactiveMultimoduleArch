import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboarding/presentation/onboarding/onboarding_cubit.dart';
import 'package:ui/tokens/colors.dart';

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

  static const _slides = [
    _SlideData(
      icon: Icons.account_balance,
      title: 'Bienvenido a BankApp',
      description:
          'Tu banco siempre contigo. Gestiona tus finanzas de forma sencilla y segura desde cualquier lugar.',
      color: BankingColors.primary,
    ),
    _SlideData(
      icon: Icons.dashboard_outlined,
      title: 'Tus cuentas, un vistazo',
      description:
          'Consulta tus saldos, movimientos y tarjetas en una sola pantalla. Todo lo que necesitas, al instante.',
      color: BankingColors.primaryLight,
    ),
    _SlideData(
      icon: Icons.security_outlined,
      title: 'Pagos seguros',
      description:
          'Realiza transferencias y pagos con la máxima seguridad. Protegemos tus operaciones con la última tecnología.',
      color: BankingColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.state.isLastPage) {
      widget.onComplete?.call();
    } else {
      cubit.nextPage();
      unawaited(_pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ));
    }
  }

  void _onSkip() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        backgroundColor: BankingColors.backgroundLight,
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Skip button.
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextButton(
                        onPressed: state.isLastPage ? null : _onSkip,
                        child: Text(
                          state.isLastPage ? '' : 'Saltar',
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
                      itemCount: _slides.length,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().setPage(index);
                      },
                      itemBuilder: (context, index) {
                        final slide = _slides[index];
                        return _OnboardingSlide(data: slide);
                      },
                    ),
                  ),
                  // Page indicators.
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_slides.length, (index) {
                        final isActive = index == state.currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 32 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? BankingColors.primary
                                : BankingColors.primary.withValues(alpha:0.2),
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
                          state.isLastPage ? 'Comenzar' : 'Siguiente',
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
              color: data.color.withValues(alpha:0.1),
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
