import 'package:common/config/environment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import './app.dart';
import './di/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    BankingApp(
      overrides: [
        CommonProviders.environment.overrideWithBuild(
          (ref, notifier) => Environment.pre,
        ),
      ],
    ),
  );
}
