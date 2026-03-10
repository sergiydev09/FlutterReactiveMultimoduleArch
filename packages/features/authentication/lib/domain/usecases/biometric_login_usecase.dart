import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/login_result.dart';
import '../repositories/auth_repository.dart';

/// Use case for authenticating the user via biometrics.
class BiometricLoginUseCase extends UseCase<LoginResult, NoParams> {
  BiometricLoginUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginResult>> call(NoParams params) {
    return repository.biometricLogin();
  }
}
