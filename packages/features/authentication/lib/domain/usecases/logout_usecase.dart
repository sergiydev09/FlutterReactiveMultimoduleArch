import 'package:authentication/domain/repositories/auth_repository.dart';
import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for logging out the current user.
class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
