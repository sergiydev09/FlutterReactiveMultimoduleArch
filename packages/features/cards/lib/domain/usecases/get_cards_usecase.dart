import 'package:cards/domain/repositories/card_repository.dart';
import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Fetches all cards for the current user.
class GetCardsUseCase extends UseCase<List<CardEntity>, NoParams> {
  GetCardsUseCase({required this.repository});

  final CardRepository repository;

  @override
  Future<Either<Failure, List<CardEntity>>> call(NoParams params) {
    return repository.getCards();
  }
}
