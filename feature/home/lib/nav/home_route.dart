import 'package:arch/navigation/feature_route.dart';
import 'package:flutter/material.dart';
import 'package:home/di/get_it.dart';
import 'package:home/ui/home_view_model.dart';
import 'package:home/ui/screen/desktop/home_screen_desktop.dart';
import 'package:home/ui/screen/mobile/home_screen_mobile.dart';

class HomeRoute extends FeatureRoute {
  HomeRoute(super.context);

  final _homeViewModel = getIt<HomeViewModel>();

  @override
  Widget get mobileScreen => HomeScreenMobile(viewModel: _homeViewModel);

  @override
  Widget get desktopScreen => HomeScreenDesktop(viewModel: _homeViewModel);
}
