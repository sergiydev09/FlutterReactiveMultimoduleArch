import 'package:authentication/routing/auth_routes.dart';
import 'package:common/config/environment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mock/mock.dart';
import 'package:security/security.dart';
import './app.dart';
import './di/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Security: no-op en dev para evitar falsos positivos en emuladores.
  final securityInitializer = SecurityInitializer(
    threatDetector: NoOpDeviceThreatDetector(),
    screenProtection: ScreenProtectionService(),
    policy: ThreatPolicy.warn,
  );
  await securityInitializer.initialize();

  runApp(
    BankingApp(
      overrides: [
        AuthRoutes.showEnvironmentSelector.overrideWithValue(true),
        // Threat detector no-op en dev (emuladores).
        SecurityProviders.threatDetector.overrideWithValue(
          NoOpDeviceThreatDetector(),
        ),
        AuthProviders.remoteDataSource.overrideWith((ref) {
          final env = ref.watch(CommonProviders.environment);
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
        MainShellProviders.dataSource.overrideWithValue(
          MockProviders.mockShellConfigDataSource,
        ),
      ],
    ),
  );
}
