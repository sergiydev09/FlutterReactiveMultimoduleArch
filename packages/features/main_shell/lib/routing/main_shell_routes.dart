import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/security.dart';

import '../di/main_shell_providers.dart';
import '../presentation/shell/bloc/main_shell_bloc.dart';
import '../presentation/shell/page/main_shell_page.dart';

/// Provides the [ShellRoute] builder for the main shell.
///
/// Usage in `app_router.dart`:
/// ```dart
/// ShellRoute(
///   builder: MainShellRoutes.builder,
///   routes: [ ... ],
/// )
/// ```
abstract final class MainShellRoutes {
  /// ShellRoute builder — creates the [MainShellBloc] and [MainShellPage].
  static Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    final container = ProviderScope.containerOf(context);
    final userInfo = container.read(SecurityProviders.userSession).value;

    return BlocProvider(
      create: (_) => MainShellBloc(
        getShellConfigUseCase: container.read(
          MainShellProviders.getShellConfigUseCase,
        ),
        onLogout: () async {
          await container
              .read(SecurityProviders.sessionManager.notifier)
              .clearSession();
          container.read(SecurityProviders.userSession.notifier).clear();
        },
      )..add(const ShellStarted()),
      child: MainShellPage(
        userName: userInfo?.fullName ?? '',
        userInitials: userInfo?.initials ?? '?',
        child: child,
      ),
    );
  }
}
