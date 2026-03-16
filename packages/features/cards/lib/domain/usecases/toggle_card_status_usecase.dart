import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/card_repository.dart';

/// Toggles the active/blocked status of a card by its ID.
///
/// Returns the updated [CardEntity] on success.
class ToggleCardStatusUseCase extends UseCase<CardEntity, String> {
  ToggleCardStatusUseCase({required this.repository});

  final CardRepository repository;

  @override
  Future<Either<Failure, CardEntity>> call(String params) {
    return repository.toggleCardStatus(params);
  }
}
