import 'package:json_annotation/json_annotation.dart';
import '../../domain/promo_banner.dart';

part 'generated/promo_banner_dto.g.dart';

@JsonSerializable()
class PromoBannerDto {
  const PromoBannerDto({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionUrl,
    required this.actionType,
    this.priority = 0,
  });

  factory PromoBannerDto.fromJson(Map<String, dynamic> json) =>
      _$PromoBannerDtoFromJson(json);

  final String id;
  final String title;
  final String subtitle;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'action_url')
  final String actionUrl;
  @JsonKey(name: 'action_type')
  final String actionType;
  final int priority;

  Map<String, dynamic> toJson() => _$PromoBannerDtoToJson(this);

  PromoBanner toEntity() {
    return PromoBanner(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      actionType: actionType == 'webview'
          ? PromoActionType.webview
          : PromoActionType.deepLink,
      priority: priority,
    );
  }
}
