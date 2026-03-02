import 'package:common/error/failures.dart';
import 'package:common/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:payments/domain/entities/payment.dart';
import 'package:payments/domain/repositories/payment_repository.dart';

/// Executes a payment and returns the confirmation ID.
class ExecutePaymentUseCase extends UseCase<String, Payment> {
  ExecutePaymentUseCase({required this.repository});

  final PaymentRepository repository;

  @override
  Future<Either<Failure, String>> call(Payment params) {
    return repository.executePayment(params);
  }
}
