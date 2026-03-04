import 'package:common/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import '../entities/payment.dart';

/// Repository contract for payment operations.
abstract class PaymentRepository {
  /// Executes the given [payment].
  ///
  /// Returns the payment confirmation ID on success.
  Future<Either<Failure, String>> executePayment(Payment payment);
}
