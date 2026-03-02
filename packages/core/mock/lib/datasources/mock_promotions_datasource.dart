import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';
import 'package:promotions/data/promotions_datasource.dart';
import 'package:promotions/domain/promo_banner.dart';

class MockPromotionsDataSource implements RemotePromotionsDataSource {
  MockPromotionsDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<List<PromoBanner>> fetchPromotions() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/promotions.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return PromoBanner(
        id: map['id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        imageUrl: map['image_url'] as String? ?? '',
        actionUrl: map['action_url'] as String,
        actionType: (map['action_type'] as String) == 'webview'
            ? PromoActionType.webview
            : PromoActionType.deepLink,
        priority: map['priority'] as int? ?? 0,
      );
    }).toList();
  }
}
