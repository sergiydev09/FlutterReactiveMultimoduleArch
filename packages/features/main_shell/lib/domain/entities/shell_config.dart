import 'bottom_tab.dart';
import 'drawer_item.dart';

/// Complete shell layout configuration.
///
/// Today this is static. In the future, the datasource can fetch it
/// from a remote config service to enable dynamic menus.
class ShellConfig {
  const ShellConfig({
    required this.drawerItems,
    required this.bottomTabs,
  });

  final List<DrawerItem> drawerItems;
  final List<BottomTab> bottomTabs;
}
