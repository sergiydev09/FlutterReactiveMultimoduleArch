import 'package:payments/data/models/payment_request_dto.dart';
import 'package:payments/data/models/payment_response_dto.dart';

/// Remote data source contract for payment operations.
abstract class RemotePaymentDataSource {
  /// Executes the given [request].
  ///
  /// Returns a [PaymentResponseDto] with the confirmation ID on success.
  /// Throws an exception on failure.
  Future<PaymentResponseDto> executePayment(PaymentRequestDto request);
}
