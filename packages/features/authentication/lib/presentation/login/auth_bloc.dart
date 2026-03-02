import 'package:authentication/domain/entities/login_credentials.dart';
import 'package:authentication/domain/usecases/login_usecase.dart';
import 'package:authentication/domain/usecases/logout_usecase.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC responsible for managing authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

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
    // Biometric login would be handled here by verifying biometrics
    // and then using stored credentials.
    emit(const AuthError(message: 'Autenticación biométrica no disponible'));
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
