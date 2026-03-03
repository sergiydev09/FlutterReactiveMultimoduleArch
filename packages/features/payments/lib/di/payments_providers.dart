import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payments/data/datasources/remote_payment_datasource.dart';
import 'package:payments/data/repositories/payment_repository_impl.dart';
import 'package:payments/domain/repositories/payment_repository.dart';

/// Riverpod providers for the payments feature.
abstract final class PaymentProviders {
  /// Remote data source. Must be overridden in each entry point.
  static final remoteDataSource = Provider<RemotePaymentDataSource>((ref) {
    throw UnimplementedError('Must be overridden');
  });

  /// Repository for payment operations.
  static final repository = Provider<PaymentRepository>((ref) {
    return PaymentRepositoryImpl(
      remoteDataSource: ref.watch(PaymentProviders.remoteDataSource),
    );
  });
}
