import 'package:accounts/di/accounts_providers.dart';
import 'package:accounts/domain/usecases/get_account_detail_usecase.dart';
import 'package:accounts/domain/usecases/get_account_transactions_usecase.dart';
import 'package:accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:accounts/presentation/account_detail/account_detail_bloc.dart';
import 'package:accounts/presentation/account_detail/account_detail_page.dart';
import 'package:accounts/presentation/account_transactions/account_transactions_bloc.dart';
import 'package:accounts/presentation/accounts_list/accounts_list_bloc.dart';
import 'package:accounts/presentation/accounts_list/accounts_list_page.dart';
import 'package:accounts/presentation/transaction_detail/transaction_detail_page.dart';
import 'package:common/routing/feature_routes.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route path constants for the accounts feature.
abstract final class AccountPaths {
  static const accounts = '/accounts';
  static const _idSegment = ':id';
  static const _transactionsSegment = 'transactions/:txId';

  /// Returns the path for a specific account detail.
  static String accountById(String id) => '/accounts/$id';

  /// Returns the path for a specific transaction detail.
  static String transaction({
    required String accountId,
    required String txId,
  }) => '/accounts/$accountId/transactions/$txId';
}

/// Builds the accounts feature routes.
FeatureRoutes accountRoutes() {
  return FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: AccountPaths.accounts,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          final accountRepo = container.read(AccountProviders.repository);
          return BlocProvider(
            create: (_) => AccountsListBloc(
              getAccountsUseCase: GetAccountsUseCase(repository: accountRepo),
            )..add(const LoadAccounts()),
            child: const AccountsListPage(),
          );
        },
        routes: [
          GoRoute(
            path: AccountPaths._idSegment,
            builder: (context, state) {
              final container = ProviderScope.containerOf(context);
              final accountRepo = container.read(AccountProviders.repository);
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
                path: AccountPaths._transactionsSegment,
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
    ],
  );
}
