import 'dart:async';
import 'package:common/common.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:security/security.dart';
import '../di/auth_providers.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../presentation/forgot_password/page/forgot_password_page.dart';
import '../presentation/login/bloc/login_bloc.dart';
import '../presentation/login/page/login_page.dart';

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
            showEnvironmentSelector: container.read(showEnvironmentSelector),
            onEnvironmentChanged: (env) {
              container.read(CommonProviders.environment.notifier).set(env);
            },
            onLoginSuccess: (user) {
              container
                  .read(SecurityProviders.isLoggedIn.notifier)
                  .set(value: true);
              container
                  .read(SecurityProviders.currentUserName.notifier)
                  .set(user.fullName);
            },
            onForgotPassword: () => context.go(forgotPassword),
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

/// Manages [LoginBloc] lifecycle and builds [LoginPage] with reactive values.
///
/// Watches [SecurityProviders.biometricEnabled] so the biometric button
/// appears as soon as the async provider loads — without requiring a
/// navigation round-trip.
///
/// When the environment switches, a new BLoC is created with the updated
/// repository while keeping [LoginPage] (and its text fields) intact.
class LoginBlocScope extends ConsumerStatefulWidget {
  const LoginBlocScope({
    super.key,
    this.showEnvironmentSelector = false,
    this.onForgotPassword,
    this.onLoginSuccess,
    this.onEnvironmentChanged,
  });

  final bool showEnvironmentSelector;
  final VoidCallback? onForgotPassword;
  final ValueChanged<User>? onLoginSuccess;
  final ValueChanged<Environment>? onEnvironmentChanged;

  @override
  ConsumerState<LoginBlocScope> createState() => _LoginBlocScopeState();
}

class _LoginBlocScopeState extends ConsumerState<LoginBlocScope> {
  late LoginBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = _createBloc();
  }

  LoginBloc _createBloc() {
    final authRepo = ref.read(AuthProviders.repository);
    return LoginBloc(
      loginUseCase: LoginUseCase(repository: authRepo),
      logoutUseCase: LogoutUseCase(repository: authRepo),
      biometricLoginUseCase: ref.read(AuthProviders.biometricLoginUseCase),
    );
  }

  @override
  void dispose() {
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(CommonProviders.environment, (_, _) {
      final oldBloc = _bloc;
      setState(() {
        _bloc = _createBloc();
      });
      unawaited(oldBloc.close());
    });

    final isBiometricEnabled =
        ref.watch(SecurityProviders.biometricEnabled).value ?? false;

    return BlocProvider.value(
      value: _bloc,
      child: LoginPage(
        showEnvironmentSelector: widget.showEnvironmentSelector,
        isBiometricEnabled: isBiometricEnabled,
        onForgotPassword: widget.onForgotPassword,
        onLoginSuccess: widget.onLoginSuccess,
        onEnvironmentChanged: widget.onEnvironmentChanged,
      ),
    );
  }
}
