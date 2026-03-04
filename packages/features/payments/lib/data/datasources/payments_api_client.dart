import 'package:dio/dio.dart';
import 'package:payments/data/models/payment_request_dto.dart';
import 'package:payments/data/models/payment_response_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'generated/payments_api_client.g.dart';

@RestApi()
abstract class PaymentsApiClient {
  factory PaymentsApiClient(Dio dio, {String? baseUrl}) = _PaymentsApiClient;

  @POST('/payments')
  Future<PaymentResponseDto> executePayment(
    @Body() PaymentRequestDto request,
  );
}
