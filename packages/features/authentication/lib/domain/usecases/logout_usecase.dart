import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/auth_repository.dart';

/// Revokes the current user's token via the authentication API and clears
/// the local session via the shared LogoutDataSource.
///
/// This use case is specific to the authentication feature because it calls
/// an auth API endpoint. For local-only session clearing (e.g. from settings
/// or the main shell), use SecurityProviders.logoutUseCase instead.
class AuthLogoutUseCase extends UseCase<void, NoParams> {
  AuthLogoutUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
