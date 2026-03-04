import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/account_repository.dart';

/// Fetches a single account's detail by its ID.
class GetAccountDetailUseCase extends UseCase<Account, String> {
  GetAccountDetailUseCase({required this.repository});

  final AccountRepository repository;

  @override
  Future<Either<Failure, Account>> call(String params) {
    return repository.getAccountDetail(params);
  }
}
