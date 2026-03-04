import 'package:authentication/domain/entities/login_credentials.dart';
import 'package:authentication/domain/usecases/biometric_login_usecase.dart';
import 'package:authentication/domain/usecases/login_usecase.dart';
import 'package:authentication/domain/usecases/logout_usecase.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'generated/auth_bloc.freezed.dart';

/// BLoC responsible for managing authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required BiometricLoginUseCase biometricLoginUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _biometricLoginUseCase = biometricLoginUseCase,
       super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final BiometricLoginUseCase _biometricLoginUseCase;

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginCredentials(dni: event.dni, password: event.password),
    );

    result.match(
      (failure) => emit(AuthError(message: failure.message)),
      (loginResult) => emit(AuthAuthenticated(user: loginResult.user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _logoutUseCase(const NoParams());

    result.match(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _biometricLoginUseCase(const NoParams());

    result.match(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Check for stored tokens/session.
    emit(const AuthUnauthenticated());
  }
}
