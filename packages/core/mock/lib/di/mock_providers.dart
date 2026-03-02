import 'package:mock/datasources/mock_account_datasource.dart';
import 'package:mock/datasources/mock_auth_datasource.dart';
import 'package:mock/datasources/mock_card_datasource.dart';
import 'package:mock/datasources/mock_globalposition_datasource.dart';
import 'package:mock/datasources/mock_notification_datasource.dart';
import 'package:mock/datasources/mock_payment_datasource.dart';
import 'package:mock/datasources/mock_promotions_datasource.dart';

class MockProviders {
  static final mockAuthDataSource = MockAuthDataSource();
  static final mockAccountDataSource = MockAccountDataSource();
  static final mockGlobalPositionDataSource = MockGlobalPositionDataSource();
  static final mockPaymentDataSource = MockPaymentDataSource();
  static final mockCardDataSource = MockCardDataSource();
  static final mockNotificationDataSource = MockNotificationDataSource();
  static final mockPromotionsDataSource = MockPromotionsDataSource();
}
