import 'package:flutter/material.dart';
import 'package:home/di/get_it.dart';
import 'package:home/ui/home_view_model.dart';
import 'package:home/ui/screen/desktop/home_screen_desktop.dart';
import 'package:home/ui/screen/mobile/home_screen_mobile.dart';
import 'package:arch/navigation/feature_route.dart';

class HomeRoute extends FeatureRoute {
  HomeRoute(super.context);

  @override
  Widget get mobileScreen => const HomeScreenMobile();

  @override
  Widget get desktopScreen {
    final homeViewModel = getIt<HomeViewModel>();
    return HomeScreenDesktop(viewModel: homeViewModel);
  }
}