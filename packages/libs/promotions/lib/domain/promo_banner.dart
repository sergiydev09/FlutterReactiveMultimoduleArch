import 'package:equatable/equatable.dart';

/// The type of action triggered when a promo banner is tapped.
enum PromoActionType {
  /// Navigate using an in-app deep link.
  deepLink,

  /// Open in a WebView.
  webview,
}

/// Represents a promotional banner displayed in the app.
class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionUrl,
    required this.actionType,
    this.priority = 0,
  });

  /// Unique identifier.
  final String id;

  /// Banner headline.
  final String title;

  /// Banner subheading.
  final String subtitle;

  /// URL of the banner image.
  final String imageUrl;

  /// URL or deep link triggered on tap.
  final String actionUrl;

  /// How the action should be handled.
  final PromoActionType actionType;

  /// Display priority (higher = shown first).
  final int priority;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imageUrl,
    actionUrl,
    actionType,
    priority,
  ];
}
