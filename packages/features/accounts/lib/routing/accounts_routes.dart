import 'dart:async';

import 'package:common/routing/feature_routes.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/di/security_providers.dart';
import '../di/accounts_providers.dart';
import '../domain/usecases/get_account_detail_usecase.dart';
import '../domain/usecases/get_account_transactions_usecase.dart';
import '../domain/usecases/get_accounts_usecase.dart';
import '../presentation/account_detail/bloc/account_detail_bloc.dart';
import '../presentation/account_detail/page/account_detail_page.dart';
import '../presentation/account_transactions/bloc/account_transactions_bloc.dart';
import '../presentation/accounts_list/bloc/accounts_list_bloc.dart';
import '../presentation/accounts_list/page/accounts_list_page.dart';
import '../presentation/transaction_detail/page/transaction_web_detail_page.dart';

/// Route paths and route definitions for the accounts feature.
abstract final class AccountRoutes {
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

  static final routes = FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: accounts,
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
            path: _idSegment,
            builder: (context, state) {
              final container = ProviderScope.containerOf(context);
              final accountRepo = container.read(AccountProviders.repository);
              final accountId = state.pathParameters['id']!;
              final accountName = state.extra as String?;
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
                child: AccountDetailPage(
                  accountName: accountName,
                  onTransactionTap: (tx) {
                    unawaited(context.push(
                      AccountRoutes.transaction(
                        accountId: accountId,
                        txId: tx.id,
                      ),
                      extra: tx,
                    ));
                  },
                ),
              );
            },
            routes: [
              GoRoute(
                path: _transactionsSegment,
                builder: (context, state) {
                  final transaction = state.extra as Transaction?;
                  if (transaction == null) {
                    return const Scaffold(
                      body: Center(
                        child: Text('Transaccion no encontrada'),
                      ),
                    );
                  }
                  final container = ProviderScope.containerOf(context);
                  return TransactionWebDetailPage(
                    transaction: transaction,
                    sessionManager: container.read(
                      SecurityProviders.sessionManager.notifier,
                    ),
                    accountRepository: container.read(
                      AccountProviders.repository,
                    ),
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
