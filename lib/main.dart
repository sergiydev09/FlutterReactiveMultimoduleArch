import 'package:flutter/material.dart';
import 'package:flutter_arch/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home/di/get_it.dart';
import 'package:res/theme/theme.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Arch Proposal',
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('es', ''),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode) {
              if (locale?.languageCode == 'es') {
                return const Locale('es', '');
              } else {
                return const Locale('en', '');
              }
            }
          }
          // If the device language is not supported, default to English
          return const Locale('en', '');
        },
        theme: MarvelTheme.themeData,
        initialRoute: Routes.home,
        routes: Routes.getRoutes(context),
        navigatorObservers: [MyNavigatorObserver()],
        debugShowCheckedModeBanner: false,
      );
}
