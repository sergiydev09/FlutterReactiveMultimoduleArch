import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/auth_repository.dart';

/// Use case for authenticating the user via biometrics.
class BiometricLoginUseCase extends UseCase<User, NoParams> {
  BiometricLoginUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return repository.biometricLogin();
  }
}
