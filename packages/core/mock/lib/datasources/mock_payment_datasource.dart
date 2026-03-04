import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/data/models/payment_request_dto.dart';
import 'package:payments/data/models/payment_response_dto.dart';

class MockPaymentDataSource implements RemotePaymentDataSource {
  MockPaymentDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<PaymentResponseDto> executePayment(
    PaymentRequestDto request,
  ) async {
    await MockDelay.simulate(config);
    return PaymentResponseDto(
      confirmationId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
