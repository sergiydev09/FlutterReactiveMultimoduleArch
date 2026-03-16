import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/settings_repository.dart';

/// Toggles the biometric login preference and returns the new value.
class ToggleBiometricsUseCase extends UseCase<bool, NoParams> {
  ToggleBiometricsUseCase({required this.repository});

  final SettingsRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repository.toggleBiometrics();
}
