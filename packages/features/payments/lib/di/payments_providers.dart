import 'package:common/di/common_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/data/datasources/payments_api_client.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/data/repositories/payment_repository_impl.dart';
import 'package:payments/domain/repositories/payment_repository.dart';

/// Riverpod providers for the payments feature.
abstract final class PaymentProviders {
  /// Retrofit API client.
  static final apiClient = Provider<PaymentsApiClient>((ref) {
    return PaymentsApiClient(ref.watch(CommonProviders.dio));
  });

  /// Remote data source. Defaults to Retrofit impl; overridden with mocks
  /// in main_dev.dart.
  static final remoteDataSource = Provider<RemotePaymentDataSource>((ref) {
    return RemotePaymentDataSource(
      apiClient: ref.watch(PaymentProviders.apiClient),
    );
  });

  /// Repository for payment operations.
  static final repository = Provider<PaymentRepository>((ref) {
    return PaymentRepositoryImpl(
      remoteDataSource: ref.watch(PaymentProviders.remoteDataSource),
    );
  });
}
