import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/shell_session_repository.dart';

/// Clears the active session and user data (logout from the shell).
class ShellLogoutUseCase extends UseCase<void, NoParams> {
  ShellLogoutUseCase({required this.repository});

  final ShellSessionRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.logout();
}
