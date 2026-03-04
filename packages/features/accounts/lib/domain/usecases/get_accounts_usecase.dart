import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:domain/entities/account.dart';
import 'package:fpdart/fpdart.dart';
import '../repositories/account_repository.dart';

/// Fetches all accounts for the current user.
class GetAccountsUseCase extends UseCase<List<Account>, NoParams> {
  GetAccountsUseCase({required this.repository});

  final AccountRepository repository;

  @override
  Future<Either<Failure, List<Account>>> call(NoParams params) {
    return repository.getAccounts();
  }
}
