import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';
import 'package:promotions/data/datasources/remote_promotions_datasource.dart';
import 'package:promotions/data/models/promo_banner_dto.dart';

class MockPromotionsDataSource implements RemotePromotionsDataSource {
  MockPromotionsDataSource({this.config = MockConfig.standard});
  final MockConfig config;

  @override
  Future<List<PromoBannerDto>> fetchPromotions() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/promotions.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return PromoBannerDto(
        id: map['id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        imageUrl: map['image_url'] as String? ?? '',
        actionUrl: map['action_url'] as String,
        actionType: map['action_type'] as String? ?? 'deep_link',
        priority: map['priority'] as int? ?? 0,
      );
    }).toList();
  }
}
