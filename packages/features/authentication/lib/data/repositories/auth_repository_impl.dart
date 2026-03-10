import 'package:common/error/failures.dart';
import 'package:common/extensions/either_extensions.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';
import 'package:security/biometric/biometric_service.dart';
import 'package:security/biometric/device_credential_service.dart';
import 'package:security/session/session_manager.dart';
import 'package:security/session/user_storage_keys.dart';
import 'package:security/storage/secure_storage_service.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/entities/login_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote_auth_datasource.dart';

/// Concrete implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.biometricService,
    required this.deviceCredentialService,
    required this.sessionManager,
    required this.secureStorage,
  });

  final RemoteAuthDataSource remoteDataSource;
  final BiometricService biometricService;
  final DeviceCredentialService deviceCredentialService;
  final SessionManager sessionManager;
  final SecureStorageService secureStorage;

  // ---------------------------------------------------------------------------
  // Credential login
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, LoginResult>> login(
    LoginCredentials credentials,
  ) =>
      safeApiCall(() async {
        final response = await remoteDataSource.login(
          credentials.dni,
          credentials.password,
        );
        final token = response.token.toEntity();
        final user = response.user.toEntity();

        await sessionManager.saveToken(token.accessToken);
        await sessionManager.saveRefreshToken(token.refreshToken);
        await _persistUser(user);

        return LoginResult(token: token, user: user);
      });

  @override
  Future<Either<Failure, void>> logout() =>
      safeApiCall(() => remoteDataSource.logout(''));

  // ---------------------------------------------------------------------------
  // Biometric login
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, LoginResult>> biometricLogin() async {
    // 1. Check biometric availability.
    final isAvailable = await biometricService.isAvailable();
    if (!isAvailable) {
      return const AuthFailure(
        message: 'Biometría no disponible en este dispositivo',
      ).toLeft();
    }

    // 2. Check device credentials are enrolled.
    final isEnrolled = await deviceCredentialService.isEnrolled();
    if (!isEnrolled) {
      return const AuthFailure(
        message: 'Login biométrico no configurado',
      ).toLeft();
    }

    // 3. Get challenge from backend.
    return safeApiCall(() async {
      final deviceId = await deviceCredentialService.getDeviceId();
      final challenge = await remoteDataSource.getBiometricChallenge(deviceId);

      // 4. Biometric verification + sign challenge (single prompt).
      final result = await deviceCredentialService.authenticate(challenge);

      // 5. Send signed challenge to backend → get tokens + user.
      final response = await remoteDataSource.verifyBiometric(
        signature: result.signature,
        deviceId: result.deviceId,
      );
      final token = response.token.toEntity();
      final user = response.user.toEntity();

      await sessionManager.saveToken(token.accessToken);
      await sessionManager.saveRefreshToken(token.refreshToken);
      await _persistUser(user);

      return LoginResult(token: token, user: user);
    });
  }

  // ---------------------------------------------------------------------------
  // Biometric enrollment
  // ---------------------------------------------------------------------------

  @override
  Future<Either<Failure, void>> enrollBiometric() =>
      safeApiCall(() async {
        final publicKey = await deviceCredentialService.enroll();
        final deviceId = await deviceCredentialService.getDeviceId();
        await remoteDataSource.registerDevice(
          publicKey: publicKey,
          deviceId: deviceId,
        );
      });

  @override
  Future<Either<Failure, void>> unenrollBiometric() =>
      safeApiCall(() async {
        final deviceId = await deviceCredentialService.getDeviceId();
        await remoteDataSource.unregisterDevice(deviceId);
        await deviceCredentialService.unenroll();
      });

  // ---------------------------------------------------------------------------
  // User persistence
  // ---------------------------------------------------------------------------

  Future<void> _persistUser(User user) async {
    await secureStorage.write(UserStorageKeys.id, user.id);
    await secureStorage.write(UserStorageKeys.dni, user.dni);
    await secureStorage.write(UserStorageKeys.firstName, user.firstName);
    await secureStorage.write(UserStorageKeys.lastName, user.lastName);
    await secureStorage.write(UserStorageKeys.email, user.email);
    await secureStorage.write(
      UserStorageKeys.createdAt,
      user.createdAt.toIso8601String(),
    );
    if (user.phone != null) {
      await secureStorage.write(UserStorageKeys.phone, user.phone!);
    }
  }
}
