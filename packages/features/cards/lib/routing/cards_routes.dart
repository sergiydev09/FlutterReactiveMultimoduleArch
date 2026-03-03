import 'package:cards/di/cards_providers.dart';
import 'package:cards/domain/usecases/get_cards_usecase.dart';
import 'package:cards/presentation/card_detail/card_detail_page.dart';
import 'package:cards/presentation/cards_list/cards_bloc.dart';
import 'package:cards/presentation/cards_list/cards_list_page.dart';
import 'package:common/routing/feature_routes.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          final cardRepo = container.read(CardProviders.repository);
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
            path: _idSegment,
            builder: (context, state) {
              final card = state.extra as CardEntity?;
              if (card != null) {
                final container = ProviderScope.containerOf(context);
                final cardRepo = container.read(CardProviders.repository);
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
    ],
  );
}
