import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../repositories/account_repository.dart';

/// Fetches the WebView URL for the transaction detail screen.
class GetTransactionDetailUrlUseCase extends UseCase<String, String> {
  GetTransactionDetailUrlUseCase({required this.repository});

  final AccountRepository repository;

  @override
  Future<Either<Failure, String>> call(String params) {
    return repository.getTransactionDetailUrl(params);
  }
}
