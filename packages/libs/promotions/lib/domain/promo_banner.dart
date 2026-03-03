import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/promo_banner.freezed.dart';

/// The type of action triggered when a promo banner is tapped.
enum PromoActionType {
  /// Navigate using an in-app deep link.
  deepLink,

  /// Open in a WebView.
  webview,
}

/// Represents a promotional banner displayed in the app.
@freezed
abstract class PromoBanner with _$PromoBanner {
  const factory PromoBanner({
    required String id,
    required String title,
    required String subtitle,
    required String imageUrl,
    required String actionUrl,
    required PromoActionType actionType,
    @Default(0) int priority,
  }) = _PromoBanner;
}
