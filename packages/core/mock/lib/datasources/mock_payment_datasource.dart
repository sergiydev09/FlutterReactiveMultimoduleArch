import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/domain/entities/payment.dart';

class MockPaymentDataSource implements RemotePaymentDataSource {
  MockPaymentDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<String> executePayment(Payment payment) async {
    await MockDelay.simulate(config);
    return 'PAY-${DateTime.now().millisecondsSinceEpoch}';
  }
}
