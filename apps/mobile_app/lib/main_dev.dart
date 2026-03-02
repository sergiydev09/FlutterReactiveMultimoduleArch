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
        remoteAuthDataSourceProvider.overrideWith((ref) {
          final env = ref.watch(environmentProvider);
          return env == Environment.mock
              ? MockProviders.mockAuthDataSource
              : UnimplementedAuthDataSource();
        }),
        remoteAccountDataSourceProvider.overrideWithValue(
          MockProviders.mockAccountDataSource,
        ),
        remoteGlobalPositionDataSourceProvider.overrideWithValue(
          MockProviders.mockGlobalPositionDataSource,
        ),
        remotePaymentDataSourceProvider.overrideWithValue(
          MockProviders.mockPaymentDataSource,
        ),
        remoteCardDataSourceProvider.overrideWithValue(
          MockProviders.mockCardDataSource,
        ),
        remoteNotificationDataSourceProvider.overrideWithValue(
          MockProviders.mockNotificationDataSource,
        ),
        remotePromotionsDataSourceProvider.overrideWithValue(
          MockProviders.mockPromotionsDataSource,
        ),
      ],
      child: const BankingApp(showEnvironmentSelector: true),
    ),
  );
}
