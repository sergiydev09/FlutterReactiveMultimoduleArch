import 'package:common/routing/feature_routes.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../di/cards_providers.dart';
import '../presentation/card_detail/page/card_detail_page.dart';
import '../presentation/cards_list/bloc/cards_list_bloc.dart';
import '../presentation/cards_list/page/cards_list_page.dart';

/// Route paths and route definitions for the cards feature.
abstract final class CardRoutes {
  static const cards = '/cards';
  static const _idSegment = ':id';

  /// Returns the path for a specific card detail.
  static String cardById(String id) => '/cards/$id';

  static final routes = FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: cards,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return BlocProvider(
            create: (_) => CardsListBloc(
              getCardsUseCase: container.read(CardProviders.getCardsUseCase),
              cardRepository: container.read(CardProviders.repository),
            )..add(const LoadCards()),
            child: const CardsListPage(),
          );
        },
        routes: [
          GoRoute(
            path: _idSegment,
            builder: (context, state) {
              final card = state.extra as CardEntity?;
              if (card != null) {
                final container = ProviderScope.containerOf(context);
                return BlocProvider(
                  create: (_) => CardsListBloc(
                    getCardsUseCase: container.read(CardProviders.getCardsUseCase),
                    cardRepository: container.read(CardProviders.repository),
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
    ],
  );
}
