import 'package:common/config/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/app.dart';
import 'package:mobile_app/di/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        CommonProviders.environment.overrideWithBuild(
          (ref, notifier) => Environment.pro,
        ),
      ],
      child: const BankingApp(),
    ),
  );
}
