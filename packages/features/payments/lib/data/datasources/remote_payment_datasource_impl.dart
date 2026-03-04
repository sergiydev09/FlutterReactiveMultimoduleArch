import 'package:payments/data/datasources/payments_api_client.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/data/models/payment_request_dto.dart';
import 'package:payments/data/models/payment_response_dto.dart';

/// Retrofit-based implementation of [RemotePaymentDataSource].
class RemotePaymentDataSourceImpl implements RemotePaymentDataSource {
  const RemotePaymentDataSourceImpl({required this.apiClient});

  final PaymentsApiClient apiClient;

  @override
  Future<PaymentResponseDto> executePayment(
    PaymentRequestDto request,
  ) =>
      apiClient.executePayment(request);
}
