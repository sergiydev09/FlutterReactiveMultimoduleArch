import 'dart:convert';

import 'package:domain/entities/notification_entity.dart';
import 'package:flutter/services.dart';
import 'package:mock/config/mock_config.dart';
import 'package:mock/config/mock_delay.dart';
import 'package:notifications_feature/data/datasources/remote_notification_datasource.dart';

class MockNotificationDataSource implements RemoteNotificationDataSource {
  MockNotificationDataSource({this.config = MockConfig.standard});
  final MockConfig config;
  final Set<String> _readIds = {};

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await MockDelay.simulate(config);
    final jsonString = await rootBundle.loadString(
      'packages/mock/assets/fixtures/notifications.json',
    );
    final list = json.decode(jsonString) as List<dynamic>;
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final id = map['id'] as String;
      return NotificationEntity(
        id: id,
        title: map['title'] as String,
        body: map['body'] as String,
        type: _parseType(map['type'] as String? ?? 'info'),
        isRead: _readIds.contains(id) || (map['is_read'] as bool? ?? false),
        createdAt: DateTime.parse(map['created_at'] as String),
        deepLink: map['deep_link'] as String?,
      );
    }).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await MockDelay.simulate(config);
    _readIds.add(id);
  }

  static NotificationType _parseType(String type) {
    return switch (type.toLowerCase()) {
      'transfer' || 'payment' || 'income' => NotificationType.transaction,
      'security' || 'alert' => NotificationType.security,
      'promotion' => NotificationType.promotion,
      'system' => NotificationType.system,
      _ => NotificationType.info,
    };
  }
}
