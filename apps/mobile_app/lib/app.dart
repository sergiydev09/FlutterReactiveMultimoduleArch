import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/routing/app_router.dart';
import 'package:ui/theme/banking_theme.dart';

class BankingApp extends ConsumerWidget {

  const BankingApp({
    this.showEnvironmentSelector = false,
    super.key,
  });
  final bool showEnvironmentSelector;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BankApp',
      debugShowCheckedModeBanner: false,
      theme: BankingTheme.light,
      darkTheme: BankingTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
