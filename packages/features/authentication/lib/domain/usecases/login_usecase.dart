import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/login_credentials.dart';
import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

/// Use case for authenticating a user with login credentials.
class LoginUseCase extends UseCase<LoginResult, LoginCredentials> {
  LoginUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginResult>> call(LoginCredentials params) {
    return repository.login(params);
  }
}
