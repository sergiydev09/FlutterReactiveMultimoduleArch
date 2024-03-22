import 'package:arch/navigation/feature_route.dart';
import 'package:flutter/material.dart';

import 'screen/desktop/DetailScreenDesktop.dart';
import 'screen/mobile/DetailScreenMobile.dart';

class DetailRoute extends FeatureRoute {
  DetailRoute(super.context);

  @override
  Widget get mobileScreen => const DetailScreenMobile();

  @override
  Widget get desktopScreen => const DetailScreenDesktop();
}
