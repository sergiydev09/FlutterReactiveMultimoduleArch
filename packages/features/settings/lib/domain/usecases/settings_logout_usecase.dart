import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/settings_repository.dart';

/// Clears the active session and user data (logout).
class SettingsLogoutUseCase extends UseCase<void, NoParams> {
  SettingsLogoutUseCase({required this.repository});

  final SettingsRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.logout();
}
