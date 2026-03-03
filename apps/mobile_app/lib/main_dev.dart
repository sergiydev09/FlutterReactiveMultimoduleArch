import 'package:common/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app.dart';
import 'package:mobile_app/di/providers.dart';
import 'package:mock/mock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        AuthProviders.remoteDataSource.overrideWith((ref) {
          final env = ref.watch(environmentProvider);
          return env == Environment.mock
              ? MockProviders.mockAuthDataSource
              : UnimplementedAuthDataSource();
        }),
        AccountProviders.remoteDataSource.overrideWithValue(
          MockProviders.mockAccountDataSource,
        ),
        GlobalPositionProviders.remoteDataSource.overrideWithValue(
          MockProviders.mockGlobalPositionDataSource,
        ),
        PaymentProviders.remoteDataSource.overrideWithValue(
          MockProviders.mockPaymentDataSource,
        ),
        CardProviders.remoteDataSource.overrideWithValue(
          MockProviders.mockCardDataSource,
        ),
        NotificationProviders.remoteDataSource.overrideWithValue(
          MockProviders.mockNotificationDataSource,
        ),
        PromotionProviders.remoteDataSource.overrideWithValue(
          MockProviders.mockPromotionsDataSource,
        ),
      ],
      child: const BankingApp(showEnvironmentSelector: true),
    ),
  );
}
