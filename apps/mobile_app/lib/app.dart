import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:ui/theme/banking_theme.dart';
import './localization/remote_delta_loader.dart';
import './routing/app_router.dart';

class BankingApp extends StatelessWidget {
  const BankingApp({
    super.key,
    this.overrides = const [],
    this.assetLoader = const RemoteDeltaLoader(),
  });

  final List<Override> overrides;
  final AssetLoader assetLoader;

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale('es'), Locale('en'), Locale('pt')],
      path: 'packages/common/assets/translations',
      fallbackLocale: const Locale('es'),
      assetLoader: assetLoader,
      child: ProviderScope(
        overrides: overrides,
        child: const _BankingAppContent(),
      ),
    );
  }
}

class _BankingAppContent extends ConsumerWidget {
  const _BankingAppContent();

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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
