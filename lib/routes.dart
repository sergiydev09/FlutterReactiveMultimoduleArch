
import 'package:detail/detail_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home/nav/home_route.dart';

class Routes {
  static String home = '/home';
  static String detail = '/detail';
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) => {
      home: (context) => HomeRoute(context).screen,
      detail: (context) => DetailRoute(context).screen,
    };
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
