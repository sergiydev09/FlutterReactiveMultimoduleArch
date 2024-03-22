import 'package:flutter/material.dart';
import 'package:flutter_arch/routes.dart';
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
        theme: MarvelTheme.themeData,
        initialRoute: Routes.home,
        routes: Routes.getRoutes(context),
        navigatorObservers: [MyNavigatorObserver()],
        debugShowCheckedModeBanner: false,
      );
}
