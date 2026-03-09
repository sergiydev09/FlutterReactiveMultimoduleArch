import 'menu_icon.dart';

/// A bottom navigation tab.
class BottomTab {
  const BottomTab({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.route,
  });

  final String id;

  /// Localization key for the tab label.
  final String titleKey;

  final MenuIcon icon;

  /// Route path to navigate to when selected.
  final String route;
}
