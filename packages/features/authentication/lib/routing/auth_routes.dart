import 'dart:async';

import 'package:authentication/di/auth_providers.dart';
import 'package:authentication/domain/usecases/login_usecase.dart';
import 'package:authentication/domain/usecases/logout_usecase.dart';
import 'package:authentication/presentation/forgot_password/forgot_password_page.dart';
import 'package:authentication/presentation/login/auth_bloc.dart';
import 'package:authentication/presentation/login/login_page.dart';
import 'package:common/config/environment.dart';
import 'package:common/routing/feature_routes.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';

/// Route path constants for the authentication feature.
abstract final class AuthPaths {
  static const login = '/login';
  static const _forgotPasswordSegment = 'forgot-password';
  static const forgotPassword = '/login/$_forgotPasswordSegment';
}

/// Builds the authentication feature routes.
///
/// [environmentProvider] is a generic listenable that triggers AuthBloc
/// recreation when the environment changes, keeping the feature decoupled
/// from the app-level provider type.
/// [onLoginSuccess] is called after successful authentication.
/// [onEnvironmentChanged] is called when the user selects a different env.
/// [showEnvironmentSelector] controls visibility of the env selector (dev).
FeatureRoutes authRoutes({
  required ProviderListenable<Object?> environmentProvider,
  required ValueChanged<User> onLoginSuccess,
  required ValueChanged<Environment> onEnvironmentChanged,
  bool showEnvironmentSelector = false,
}) {
  return FeatureRoutes(
    fullScreenRoutes: [
      GoRoute(
        path: AuthPaths.login,
        builder: (context, state) {
          return LoginBlocScope(
            environmentProvider: environmentProvider,
            child: LoginPage(
              showEnvironmentSelector: showEnvironmentSelector,
              onEnvironmentChanged: onEnvironmentChanged,
              onLoginSuccess: onLoginSuccess,
              onForgotPassword: () => context.go(AuthPaths.forgotPassword),
            ),
          );
        },
        routes: [
          GoRoute(
            path: AuthPaths._forgotPasswordSegment,
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
    required this.environmentProvider,
    required this.child,
    super.key,
  });

  /// Provider to listen for environment changes.
  final ProviderListenable<Object?> environmentProvider;
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
    ref.listen(widget.environmentProvider, (_, _) {
      final oldBloc = _bloc;
      setState(() {
        _bloc = _createBloc();
      });
      unawaited(oldBloc.close());
    });

    return BlocProvider.value(value: _bloc, child: widget.child);
  }
}
