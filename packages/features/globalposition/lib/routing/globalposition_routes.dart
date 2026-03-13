import 'dart:async';

import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/globalposition_providers.dart';
import '../presentation/global_position/bloc/global_position_bloc.dart';
import '../presentation/global_position/page/global_position_page.dart';

/// Route paths and route definitions for the global position feature.
abstract final class GlobalPositionRoutes {
  // -- Route names --
  static const globalPosition = 'global-position';

  static final routes = FeatureRoutes(
    shellRoutes: [
      GoRoute(
        name: globalPosition,
        path: '/$globalPosition',
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => GlobalPositionBloc(
              getGlobalPositionUseCase: container.read(
                GlobalPositionProviders.getGlobalPositionUseCase,
              ),
            )..add(const LoadGlobalPosition()),
            child: GlobalPositionPage(
              onAccountTap: (account) {
                unawaited(context.pushNamed(
                  'account-detail',
                  pathParameters: {'id': account.id},
                  extra: account.name,
                ));
              },
              onTransactionTap: (tx) {
                unawaited(context.pushNamed(
                  'account-transaction',
                  pathParameters: {'id': tx.accountId, 'txId': tx.id},
                  extra: tx,
                ));
              },
            ),
          );
        },
      ),
    ],
  );
}
