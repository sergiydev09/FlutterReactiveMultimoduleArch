import 'package:common/config/environment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:security/security.dart';
import './app.dart';
import './di/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Security: detección real, policy warn en staging.
  final securityInitializer = SecurityInitializer(
    threatDetector: DeviceThreatDetectorImpl(),
    screenProtection: ScreenProtectionService(),
    policy: ThreatPolicy.warn,
  );
  await securityInitializer.initialize();

  runApp(
    BankingApp(
      overrides: [
        CommonProviders.environment.overrideWithBuild(
          (ref, notifier) => Environment.pre,
        ),
        // TODO: Override attestation con IntegrityAttestationServiceImpl
        // cuando se configure el GCP project ID.
      ],
    ),
  );
}
