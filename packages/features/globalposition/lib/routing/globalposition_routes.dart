import 'package:common/routing/feature_routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globalposition/di/globalposition_providers.dart';
import 'package:globalposition/domain/usecases/get_global_position_usecase.dart';
import 'package:globalposition/presentation/global_position/global_position_bloc.dart';
import 'package:globalposition/presentation/global_position/global_position_page.dart';
import 'package:go_router/go_router.dart';

/// Route paths and route definitions for the global position feature.
abstract final class GlobalPositionRoutes {
  static const home = '/globalposition';

  static final routes = FeatureRoutes(
    shellRoutes: [
      GoRoute(
        path: home,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          final gpRepo = container.read(GlobalPositionProviders.repository);
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
    ],
  );
}
