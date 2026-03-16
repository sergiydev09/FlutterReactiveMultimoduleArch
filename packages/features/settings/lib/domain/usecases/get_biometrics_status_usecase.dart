import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/settings_repository.dart';

/// Returns whether biometric login is currently enabled.
class GetBiometricsStatusUseCase extends UseCase<bool, NoParams> {
  GetBiometricsStatusUseCase({required this.repository});

  final SettingsRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) =>
      repository.getBiometricsEnabled();
}
