import 'menu_icon.dart';

/// A drawer menu entry.
class DrawerItem {
  const DrawerItem({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.route,
    this.enabled = true,
    this.subtitleKey,
  });

  final String id;

  /// Localization key for the title.
  final String titleKey;

  final MenuIcon icon;

  /// Route path to navigate to when tapped.
  final String route;

  /// Whether the item is active and navigable.
  final bool enabled;

  /// Optional localization key for a subtitle (e.g. "Próximamente").
  final String? subtitleKey;
}
