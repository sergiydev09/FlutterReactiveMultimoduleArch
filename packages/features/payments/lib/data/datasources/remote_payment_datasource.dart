import 'package:payments/domain/entities/payment.dart';

/// Remote data source contract for payment operations.
abstract class RemotePaymentDataSource {
  /// Executes the given [payment].
  ///
  /// Returns the payment confirmation ID on success.
  /// Throws an exception on failure.
  Future<String> executePayment(Payment payment);
}
