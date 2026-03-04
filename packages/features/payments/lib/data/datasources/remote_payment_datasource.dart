import '../models/payment_request_dto.dart';
import '../models/payment_response_dto.dart';
import './payments_api_client.dart';

/// Remote data source for payment operations.
class RemotePaymentDataSource {
  const RemotePaymentDataSource({required PaymentsApiClient apiClient})
      : _apiClient = apiClient;

  final PaymentsApiClient _apiClient;

  Future<PaymentResponseDto> executePayment(PaymentRequestDto request) =>
      _apiClient.executePayment(request);
}
