import 'dart:async';

import 'package:authentication/di/auth_providers.dart';
import 'package:authentication/domain/usecases/login_usecase.dart';
import 'package:authentication/domain/usecases/logout_usecase.dart';
import 'package:authentication/presentation/forgot_password/forgot_password_page.dart';
import 'package:authentication/presentation/login/auth_bloc.dart';
import 'package:authentication/presentation/login/login_page.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/security.dart';

/// Route paths, callback providers, and route definitions for authentication.
abstract final class AuthRoutes {
  // -- Paths --
  static const login = '/login';
  static const _forgotPasswordSegment = 'forgot-password';
  static const forgotPassword = '/login/$_forgotPasswordSegment';

  // -- Config providers (overridden per entry point) --

  /// Controls visibility of the environment selector (dev only).
  static final showEnvironmentSelector = Provider<bool>((_) => false);

  // -- Routes --

  static final routes = FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: login,
        builder: (context, state) {
          final container = ProviderScope.containerOf(context);
          return LoginBlocScope(
            child: LoginPage(
              showEnvironmentSelector: container.read(showEnvironmentSelector),
              onEnvironmentChanged: (env) {
                container.read(environmentProvider.notifier).set(env);
              },
              onLoginSuccess: (user) {
                container.read(isLoggedInProvider.notifier).set(value: true);
                container
                    .read(currentUserNameProvider.notifier)
                    .set(user.fullName);
              },
              onForgotPassword: () => context.go(forgotPassword),
            ),
          );
        },
        routes: [
          GoRoute(
            path: _forgotPasswordSegment,
            builder: (context, state) => const ForgotPasswordPage(),
          ),
        ],
      ),
    ],
  );
}

/// Manages [AuthBloc] lifecycle reacting to environment changes.
///
/// When the environment switches, a new BLoC is created with the updated
/// repository while keeping [LoginPage] (and its text fields) intact.
class LoginBlocScope extends ConsumerStatefulWidget {
  const LoginBlocScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<LoginBlocScope> createState() => _LoginBlocScopeState();
}

class _LoginBlocScopeState extends ConsumerState<LoginBlocScope> {
  late AuthBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = _createBloc();
  }

  AuthBloc _createBloc() {
    final authRepo = ref.read(AuthProviders.repository);
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
