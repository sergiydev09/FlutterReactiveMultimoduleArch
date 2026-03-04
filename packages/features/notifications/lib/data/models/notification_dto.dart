import 'package:domain/entities/notification_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generated/notification_dto.g.dart';

@JsonSerializable()
class NotificationDto {
  const NotificationDto({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.deepLink,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);

  final String id;
  final String title;
  final String body;
  final String type;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'deep_link')
  final String? deepLink;

  Map<String, dynamic> toJson() => _$NotificationDtoToJson(this);

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      type: _parseType(type),
      isRead: isRead,
      createdAt: DateTime.parse(createdAt),
      deepLink: deepLink,
    );
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
