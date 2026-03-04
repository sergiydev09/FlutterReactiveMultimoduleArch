import 'package:common/error/failures.dart';
import 'package:common/extensions/either_extensions.dart';
import 'package:common/network/safe_api_call.dart';
import 'package:domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';
import 'package:security/biometric/biometric_service.dart';
import 'package:security/session/session_manager.dart';
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
    required this.sessionManager,
    required this.secureStorage,
  });

  final RemoteAuthDataSource remoteDataSource;
  final BiometricService biometricService;
  final SessionManager sessionManager;
  final SecureStorageService secureStorage;

  // Storage keys for user fields.
  static const _userId = 'user_id';
  static const _userDni = 'user_dni';
  static const _userFirstName = 'user_first_name';
  static const _userLastName = 'user_last_name';
  static const _userEmail = 'user_email';
  static const _userCreatedAt = 'user_created_at';
  static const _userPhone = 'user_phone';

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

  @override
  Future<Either<Failure, User>> biometricLogin() async {
    final isAvailable = await biometricService.isAvailable();
    if (!isAvailable) {
      return const AuthFailure(
        message: 'Biometría no disponible en este dispositivo',
      ).toLeft();
    }

    final authenticated = await biometricService.authenticate(
      reason: 'Accede a tu banca',
    );
    if (!authenticated) {
      return const AuthFailure(
        message: 'Autenticación biométrica fallida',
      ).toLeft();
    }

    final isValid = await sessionManager.isSessionValid();
    if (!isValid) {
      return const AuthFailure(
        message: 'Sesión expirada, inicia sesión de nuevo',
      ).toLeft();
    }

    final user = await _readUser();
    if (user == null) {
      return const AuthFailure(
        message: 'No se encontraron datos de sesión',
      ).toLeft();
    }

    return Right(user);
  }

  Future<void> _persistUser(User user) async {
    await secureStorage.write(_userId, user.id);
    await secureStorage.write(_userDni, user.dni);
    await secureStorage.write(_userFirstName, user.firstName);
    await secureStorage.write(_userLastName, user.lastName);
    await secureStorage.write(_userEmail, user.email);
    await secureStorage.write(_userCreatedAt, user.createdAt.toIso8601String());
    if (user.phone != null) {
      await secureStorage.write(_userPhone, user.phone!);
    }
  }

  Future<User?> _readUser() async {
    final id = await secureStorage.read(_userId);
    final dni = await secureStorage.read(_userDni);
    final firstName = await secureStorage.read(_userFirstName);
    final lastName = await secureStorage.read(_userLastName);
    final email = await secureStorage.read(_userEmail);
    final createdAtStr = await secureStorage.read(_userCreatedAt);
    final phone = await secureStorage.read(_userPhone);

    if (id == null ||
        dni == null ||
        firstName == null ||
        lastName == null ||
        email == null ||
        createdAtStr == null) {
      return null;
    }

    return User(
      id: id,
      dni: dni,
      firstName: firstName,
      lastName: lastName,
      email: email,
      createdAt: DateTime.parse(createdAtStr),
      phone: phone,
    );
  }
}
