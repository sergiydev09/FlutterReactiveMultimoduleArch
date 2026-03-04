import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';
import 'package:notifications_feature/data/models/notification_dto.dart';
import '../config/mock_config.dart';
import '../config/mock_delay.dart';

class MockNotificationDataSource implements RemoteNotificationDataSource {
  MockNotificationDataSource({this.config = MockConfig.standard});
  final MockConfig config;
  final Set<String> _readIds = {};

  @override
  Future<List<NotificationDto>> getNotifications() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/notifications.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final id = map['id'] as String;
      return NotificationDto(
        id: id,
        title: map['title'] as String,
        body: map['body'] as String,
        type: map['type'] as String? ?? 'info',
        isRead: _readIds.contains(id) || (map['is_read'] as bool? ?? false),
        createdAt: map['created_at'] as String,
        deepLink: map['deep_link'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await MockDelay.simulate(config);
    _readIds.add(id);
  }
}
