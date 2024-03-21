import 'package:detail/screen/desktop/DetailScreenDesktop.dart';
import 'package:detail/screen/mobile/DetailScreenMobile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home/ui/screen/desktop/home_screen_desktop.dart';
import 'package:home/ui/screen/mobile/home_screen_mobile.dart';

class Routes {
  static String home = '/home';
  static String detail = '/login';

  static Map<String, WidgetBuilder> getRoutes(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double largeScreenSize = 600;

    return {
      home: (context) => screenWidth > largeScreenSize ? const HomeScreenDesktop() : const HomeScreenMobile(),
      detail: (context) => screenWidth > largeScreenSize ? const DetailScreenDesktop() : const DetailScreenMobile(),
    };
  }
}


class MyNavigatorObserver extends NavigatorObserver {

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (kDebugMode) {
      print('Pushed route: ${route.settings.name}');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (kDebugMode) {
      print('Popped route: ${route.settings.name}');
    }
  }

}