import 'package:flutter/material.dart';

abstract class FeatureRoute {
  final BuildContext context;
  Widget get mobileScreen;
  Widget get desktopScreen;

  FeatureRoute(this.context);

  Widget get screen {
    final screenWidth = MediaQuery.of(context).size.width;
    const largeScreenSize = 600;
    return screenWidth > largeScreenSize ? desktopScreen : mobileScreen;
  }
}
