import 'dart:async';

import 'package:accounts/domain/usecases/get_account_detail_usecase.dart';
import 'package:accounts/domain/usecases/get_account_transactions_usecase.dart';
import 'package:accounts/presentation/account_detail/account_detail_bloc.dart';
import 'package:accounts/presentation/account_detail/account_detail_page.dart';
import 'package:accounts/presentation/account_transactions/account_transactions_bloc.dart';
import 'package:accounts/presentation/transaction_detail/transaction_detail_page.dart';
import 'package:authentication/domain/usecases/login_usecase.dart';
import 'package:authentication/domain/usecases/logout_usecase.dart';
import 'package:authentication/presentation/forgot_password/forgot_password_page.dart';
import 'package:authentication/presentation/login/auth_bloc.dart';
import 'package:authentication/presentation/login/login_page.dart';
import 'package:cards/domain/usecases/get_cards_usecase.dart';
import 'package:cards/presentation/card_detail/card_detail_page.dart';
import 'package:cards/presentation/cards_list/cards_bloc.dart';
import 'package:cards/presentation/cards_list/cards_list_page.dart';
import 'package:common/utils/formatters.dart';
import 'package:domain/entities/account.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/domain/usecases/get_global_position_usecase.dart';
import 'package:globalposition/presentation/global_position/global_position_bloc.dart';
import 'package:globalposition/presentation/global_position/global_position_page.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/di/providers.dart';
import 'package:mobile_app/routing/main_shell.dart';
import 'package:notifications_feature/presentation/notifications/notifications_bloc.dart';
import 'package:notifications_feature/presentation/notifications/notifications_page.dart';
import 'package:onboarding/presentation/onboarding/onboarding_bloc.dart';
import 'package:onboarding/presentation/onboarding/onboarding_page.dart';
import 'package:payments/domain/entities/payment.dart';
import 'package:payments/domain/usecases/execute_payment_usecase.dart';
import 'package:payments/presentation/new_payment/new_payment_page.dart';
import 'package:payments/presentation/new_payment/payment_bloc.dart';
import 'package:payments/presentation/payment_confirm/payment_confirm_page.dart';
import 'package:payments/presentation/payment_result/payment_result_page.dart';
import 'package:settings_feature/presentation/settings/settings_bloc.dart';
import 'package:settings_feature/presentation/settings/settings_page.dart';
import 'package:ui/tokens/colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);
  final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/login/forgot-password';

      if (!isLoggedIn && !loggingIn) return '/login';

      if (isLoggedIn &&
          !hasSeenOnboarding &&
          state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }

      if (isLoggedIn && loggingIn) return '/globalposition';

      return null;
    },
    routes: [
      // Login
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return _LoginBlocScope(
            child: LoginPage(
              showEnvironmentSelector: true,
              onEnvironmentChanged: (env) {
                container.read(environmentProvider.notifier).set(env);
              },
              onLoginSuccess: (user) {
                container.read(isLoggedInProvider.notifier).set(value: true);
                container
                    .read(currentUserNameProvider.notifier)
                    .set(user.fullName);
              },
              onForgotPassword: () => context.go('/login/forgot-password'),
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => OnboardingBloc(),
            child: OnboardingPage(
              onComplete: () {
                final container = ProviderScope.containerOf(context);
                container
                    .read(hasSeenOnboardingProvider.notifier)
                    .set(value: true);
                context.go('/globalposition');
              },
            ),
          );
        },
      ),
      // Main shell with bottom nav (3 tabs)
      ShellRoute(
        builder: (context, state, child) {
          final container = ProviderScope.containerOf(context);
          final userName = container.read(currentUserNameProvider);
          return MainShell(
            userName: userName,
            onLogout: () {
              container.read(isLoggedInProvider.notifier).set(value: false);
            },
            child: child,
          );
        },
        routes: [
          // Global Position
          GoRoute(
            path: '/globalposition',
            builder: (context, state) {
              final container = ProviderScope.containerOf(context);
              final gpRepo = container.read(globalPositionRepositoryProvider);
              return BlocProvider(
                create: (_) => GlobalPositionBloc(
                  getGlobalPositionUseCase: GetGlobalPositionUseCase(
                    repository: gpRepo,
                  ),
                )..add(const LoadGlobalPosition()),
                child: const GlobalPositionPage(),
              );
            },
          ),
          // Payments - new
          GoRoute(
            path: '/payments/new',
            builder: (context, state) {
              final container = ProviderScope.containerOf(context);
              final paymentRepo = container.read(paymentRepositoryProvider);
              return BlocProvider(
                create: (_) => PaymentBloc(
                  executePaymentUseCase: ExecutePaymentUseCase(
                    repository: paymentRepo,
                  ),
                ),
                child: const NewPaymentPage(),
              );
            },
          ),
          // Notifications
          GoRoute(
            path: '/notifications',
            builder: (context, state) {
              final container = ProviderScope.containerOf(context);
              final notifRepo = container.read(notificationRepositoryProvider);
              return BlocProvider(
                create: (_) => NotificationsBloc(
                  notificationRepository: notifRepo,
                )..add(const LoadNotifications()),
                child: const NotificationsPage(),
              );
            },
          ),
        ],
      ),
      // Full-screen routes (no bottom nav)
      // Accounts list
      GoRoute(
        path: '/accounts',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          final gpRepo = container.read(globalPositionRepositoryProvider);
          return BlocProvider(
            create: (_) => GlobalPositionBloc(
              getGlobalPositionUseCase: GetGlobalPositionUseCase(
                repository: gpRepo,
              ),
            )..add(const LoadGlobalPosition()),
            child: const _AccountsListPage(),
          );
        },
        routes: [
          // Account Detail
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final container = ProviderScope.containerOf(context);
              final accountRepo = container.read(accountRepositoryProvider);
              final accountId = state.pathParameters['id']!;
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => AccountDetailBloc(
                      getAccountDetailUseCase: GetAccountDetailUseCase(
                        repository: accountRepo,
                      ),
                    )..add(LoadAccountDetail(accountId: accountId)),
                  ),
                  BlocProvider(
                    create: (_) => AccountTransactionsBloc(
                      getAccountTransactionsUseCase:
                          GetAccountTransactionsUseCase(
                            repository: accountRepo,
                          ),
                    )..add(LoadTransactions(accountId: accountId)),
                  ),
                ],
                child: const AccountDetailPage(),
              );
            },
            routes: [
              GoRoute(
                path: 'transactions/:txId',
                builder: (context, state) {
                  final transaction = state.extra as Transaction?;
                  if (transaction != null) {
                    return TransactionDetailPage(transaction: transaction);
                  }
                  return const Scaffold(
                    body: Center(child: Text('Transacción no encontrada')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      // Cards
      GoRoute(
        path: '/cards',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          final cardRepo = container.read(cardRepositoryProvider);
          return BlocProvider(
            create: (_) => CardsBloc(
              getCardsUseCase: GetCardsUseCase(repository: cardRepo),
              cardRepository: cardRepo,
            )..add(const LoadCards()),
            child: const CardsListPage(),
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final card = state.extra as CardEntity?;
              if (card != null) {
                final container = ProviderScope.containerOf(context);
                final cardRepo = container.read(cardRepositoryProvider);
                return BlocProvider(
                  create: (_) => CardsBloc(
                    getCardsUseCase: GetCardsUseCase(repository: cardRepo),
                    cardRepository: cardRepo,
                  )..add(const LoadCards()),
                  child: CardDetailPage(card: card),
                );
              }
              return const Scaffold(
                body: Center(child: Text('Tarjeta no encontrada')),
              );
            },
          ),
        ],
      ),
      // Payments - confirm
      GoRoute(
        path: '/payments/confirm',
        builder: (context, state) {
          final payment = state.extra! as Payment;
          final container = ProviderScope.containerOf(context);
          final paymentRepo = container.read(paymentRepositoryProvider);
          return BlocProvider(
            create: (_) => PaymentBloc(
              executePaymentUseCase: ExecutePaymentUseCase(
                repository: paymentRepo,
              ),
            ),
            child: PaymentConfirmPage(payment: payment),
          );
        },
      ),
      // Payments - result
      GoRoute(
        path: '/payments/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PaymentResultPage(
            isSuccess: extra?['isSuccess'] as bool? ?? false,
            confirmationId: extra?['confirmationId'] as String?,
            errorMessage: extra?['errorMessage'] as String?,
          );
        },
      ),
      // Settings
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => SettingsBloc(),
            child: SettingsPage(
              onLogout: () {
                container.read(isLoggedInProvider.notifier).set(value: false);
              },
            ),
          );
        },
      ),
    ],
  );
});

/// Manages AuthBloc lifecycle reacting to environment changes.
///
/// When the environment switches, a new BLoC is created with the updated
/// repository while keeping [LoginPage] (and its text fields) intact.
class _LoginBlocScope extends ConsumerStatefulWidget {
  const _LoginBlocScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_LoginBlocScope> createState() => _LoginBlocScopeState();
}

class _LoginBlocScopeState extends ConsumerState<_LoginBlocScope> {
  late AuthBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = _createBloc();
  }

  AuthBloc _createBloc() {
    final authRepo = ref.read(authRepositoryProvider);
    return AuthBloc(
      loginUseCase: LoginUseCase(repository: authRepo),
      logoutUseCase: LogoutUseCase(repository: authRepo),
    );
  }

  @override
  void dispose() {
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(environmentProvider, (_, _) {
      final oldBloc = _bloc;
      setState(() {
        _bloc = _createBloc();
      });
      unawaited(oldBloc.close());
    });

    return BlocProvider.value(value: _bloc, child: widget.child);
  }
}

/// Simple accounts list page used by the /accounts route.
class _AccountsListPage extends StatelessWidget {
  const _AccountsListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mis cuentas'),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<GlobalPositionBloc, GlobalPositionState>(
        builder: (context, state) {
          return switch (state) {
            GPInitial() || GPLoading() => const Center(
              child: CircularProgressIndicator(
                color: BankingColors.primary,
              ),
            ),
            GPError(:final message) => Center(child: Text(message)),
            GPLoaded(:final accounts) => ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _AccountListTile(
                  account: account,
                  onTap: () => context.push('/accounts/${account.id}'),
                );
              },
            ),
          };
        },
      ),
    );
  }
}

class _AccountListTile extends StatelessWidget {
  const _AccountListTile({required this.account, this.onTap});

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: BankingColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BankingColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: BankingColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: BankingColors.onBackgroundLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.iban,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BankingColors.onBackgroundLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatCurrency(account.balance),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BankingColors.onBackgroundLight,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: BankingColors.onBackgroundLightSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
