import 'package:common/config/environment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import './app.dart';
import './di/providers.dart';
import './localization/remote_delta_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    BankingApp(
      assetLoader: const RemoteDeltaLoader(
        deltaBaseUrl: 'https://your-cdn.example.com/translations',
      ),
      overrides: [
        CommonProviders.environment.overrideWithBuild(
          (ref, notifier) => Environment.pro,
        ),
      ],
    ),
  );
}
