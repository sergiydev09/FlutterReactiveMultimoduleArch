import '../datasources/mock_account_datasource.dart';
import '../datasources/mock_auth_datasource.dart';
import '../datasources/mock_card_datasource.dart';
import '../datasources/mock_globalposition_datasource.dart';
import '../datasources/mock_notification_datasource.dart';
import '../datasources/mock_payment_datasource.dart';
import '../datasources/mock_promotions_datasource.dart';

abstract final class MockProviders {
  static final mockAuthDataSource = MockAuthDataSource();
  static final mockAccountDataSource = MockAccountDataSource();
  static final mockGlobalPositionDataSource = MockGlobalPositionDataSource();
  static final mockPaymentDataSource = MockPaymentDataSource();
  static final mockCardDataSource = MockCardDataSource();
  static final mockNotificationDataSource = MockNotificationDataSource();
  static final mockPromotionsDataSource = MockPromotionsDataSource();
}
