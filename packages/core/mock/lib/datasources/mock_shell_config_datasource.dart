import 'package:main_shell/main_shell.dart';

/// Static shell configuration for development.
///
/// Returns hardcoded drawer items and bottom tabs. In production,
/// these would come from a remote config service.
class MockShellConfigDataSource implements ShellConfigDataSource {
  @override
  Future<ShellConfig> getShellConfig() async {
    return const ShellConfig(
      drawerItems: [
        DrawerItem(
          id: 'accounts',
          titleKey: 'shell.drawer.accounts',
          icon: MenuIcon.accounts,
          route: '/accounts',
        ),
        DrawerItem(
          id: 'cards',
          titleKey: 'shell.drawer.cards',
          icon: MenuIcon.cards,
          route: '/cards',
        ),
        DrawerItem(
          id: 'settings',
          titleKey: 'shell.drawer.settings',
          icon: MenuIcon.settings,
          route: '/settings',
        ),
        DrawerItem(
          id: 'investments',
          titleKey: 'shell.drawer.investments',
          icon: MenuIcon.investments,
          route: '/investments',
          enabled: false,
          subtitleKey: 'shell.drawer.coming_soon',
        ),
        DrawerItem(
          id: 'insurance',
          titleKey: 'shell.drawer.insurance',
          icon: MenuIcon.insurance,
          route: '/insurance',
          enabled: false,
          subtitleKey: 'shell.drawer.coming_soon',
        ),
        DrawerItem(
          id: 'loans',
          titleKey: 'shell.drawer.loans',
          icon: MenuIcon.loans,
          route: '/loans',
          enabled: false,
          subtitleKey: 'shell.drawer.coming_soon',
        ),
        DrawerItem(
          id: 'offers',
          titleKey: 'shell.drawer.offers',
          icon: MenuIcon.offers,
          route: '/offers',
          enabled: false,
          subtitleKey: 'shell.drawer.coming_soon',
        ),
      ],
      bottomTabs: [
        BottomTab(
          id: 'home',
          titleKey: 'nav.home',
          icon: MenuIcon.home,
          route: '/global-position',
        ),
        BottomTab(
          id: 'payments',
          titleKey: 'nav.payments',
          icon: MenuIcon.payments,
          route: '/payments/new',
        ),
        BottomTab(
          id: 'notifications',
          titleKey: 'nav.notifications',
          icon: MenuIcon.notifications,
          route: '/notifications',
        ),
      ],
    );
  }
}
