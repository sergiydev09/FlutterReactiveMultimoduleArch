import 'package:common/config/environment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:security/security.dart';
import './app.dart';
import './di/providers.dart';
import './localization/remote_delta_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Security: detección real + policy block en producción.
  final securityInitializer = SecurityInitializer(
    threatDetector: DeviceThreatDetectorImpl(),
    screenProtection: ScreenProtectionService(),
    policy: ThreatPolicy.block,
  );
  await securityInitializer.initialize(
    onBlocked: () {
      // TODO: Mostrar pantalla de bloqueo cuando se detecten amenazas
      // críticas (root/jailbreak) en producción.
    },
  );

  runApp(
    BankingApp(
      assetLoader: const RemoteDeltaLoader(
        deltaBaseUrl: 'https://your-cdn.example.com/translations',
      ),
      overrides: [
        CommonProviders.environment.overrideWithBuild(
          (ref, notifier) => Environment.pro,
        ),
        // TODO: Override attestation con IntegrityAttestationServiceImpl
        // cuando se configure el GCP project ID.
      ],
    ),
  );
}
