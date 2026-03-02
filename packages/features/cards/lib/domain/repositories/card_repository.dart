import 'package:common/error/failures.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Repository contract for card operations.
abstract class CardRepository {
  /// Fetches all cards for the current user.
  Future<Either<Failure, List<CardEntity>>> getCards();

  /// Fetches the detail of a specific card by [id].
  Future<Either<Failure, CardEntity>> getCardDetail(String id);

  /// Toggles the active/blocked status of a card by [id].
  Future<Either<Failure, CardEntity>> toggleCardStatus(String id);
}
