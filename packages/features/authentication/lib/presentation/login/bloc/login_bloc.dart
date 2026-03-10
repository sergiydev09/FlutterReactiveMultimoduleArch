import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/login_credentials.dart';
import '../../../domain/usecases/biometric_login_usecase.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';
part 'generated/login_bloc.freezed.dart';

/// BLoC responsible for managing authentication state.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required BiometricLoginUseCase biometricLoginUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _biometricLoginUseCase = biometricLoginUseCase,
       super(const LoginInitial()) {
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
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _loginUseCase(
      LoginCredentials(dni: event.dni, password: event.password),
    );

    result.match(
      (failure) => emit(LoginError(message: failure.message)),
      (loginResult) => emit(LoginAuthenticated(user: loginResult.user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _logoutUseCase(const NoParams());

    result.match(
      (failure) => emit(LoginError(message: failure.message)),
      (_) => emit(const LoginUnauthenticated()),
    );
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    final result = await _biometricLoginUseCase(const NoParams());

    result.match(
      (failure) => emit(LoginError(message: failure.message)),
      (loginResult) => emit(LoginAuthenticated(user: loginResult.user)),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    // Check for stored tokens/session.
    emit(const LoginUnauthenticated());
  }
}
