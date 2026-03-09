import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/tokens/colors.dart';

import '../../../domain/entities/bottom_tab.dart';
import '../../../domain/entities/drawer_item.dart';
import '../../../domain/entities/menu_icon.dart';
import '../../../domain/entities/shell_config.dart';
import '../bloc/main_shell_bloc.dart';

/// App shell with drawer, bottom nav, and AppBar — driven by [ShellConfig].
class MainShellPage extends StatelessWidget {
  const MainShellPage({
    required this.child,
    this.userName = '',
    this.userInitials = '?',
    super.key,
  });

  final Widget child;
  final String userName;
  final String userInitials;

  int _selectedIndex(BuildContext context, List<BottomTab> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].route)) return i;
    }
    return 0;
  }

  String _titleForLocation(BuildContext context, List<BottomTab> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (final tab in tabs) {
      if (location.startsWith(tab.route)) return tab.titleKey.tr();
    }
    return 'app_name'.tr();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainShellBloc, MainShellState>(
      builder: (context, state) => switch (state) {
        ShellLoading() => const SizedBox.shrink(),
        ShellError(:final message) => Scaffold(
            body: Center(child: Text(message)),
          ),
        ShellReady(:final config) => _ShellScaffold(
            config: config,
            userName: userName,
            userInitials: userInitials,
            selectedIndex: _selectedIndex(context, config.bottomTabs),
            title: _titleForLocation(context, config.bottomTabs),
            child: child,
          ),
      },
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({
    required this.config,
    required this.userName,
    required this.userInitials,
    required this.selectedIndex,
    required this.title,
    required this.child,
  });

  final ShellConfig config;
  final String userName;
  final String userInitials;
  final int selectedIndex;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Find the notifications tab route for the AppBar action.
    final notificationsRoute = config.bottomTabs
        .where((t) => t.icon == MenuIcon.notifications)
        .map((t) => t.route)
        .firstOrNull;

    final location = GoRouterState.of(context).matchedLocation;
    final isHome = config.bottomTabs.isNotEmpty &&
        location.startsWith(config.bottomTabs.first.route);

    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (isHome && notificationsRoute != null)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.go(notificationsRoute),
            ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index < config.bottomTabs.length) {
            context.go(config.bottomTabs[index].route);
          }
        },
        destinations: config.bottomTabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(_outlinedIcon(tab.icon)),
                selectedIcon: Icon(_filledIcon(tab.icon)),
                label: tab.titleKey.tr(),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: BankingColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userInitials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: BankingColors.primary,
                ),
              ),
            ),
            accountName: Text(
              userName.isNotEmpty ? userName : 'shell.default_user'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            accountEmail: Text('shell.default_email'.tr()),
          ),
          ...config.drawerItems.map((item) => _drawerTile(context, item)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<MainShellBloc>().add(const LogoutRequested());
                },
                icon: const Icon(Icons.logout),
                label: Text('common.logout'.tr()),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BankingColors.error,
                  side: const BorderSide(color: BankingColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _drawerTile(BuildContext context, DrawerItem item) {
    final iconData = _outlinedIcon(item.icon);
    final color = item.enabled ? null : Colors.grey;

    return ListTile(
      leading: Icon(iconData, color: color),
      title: Text(
        item.titleKey.tr(),
        style: item.enabled ? null : const TextStyle(color: Colors.grey),
      ),
      subtitle: item.subtitleKey != null
          ? Text(
              item.subtitleKey!.tr(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      enabled: item.enabled,
      onTap: item.enabled
          ? () {
              Navigator.pop(context);
              unawaited(context.push(item.route));
            }
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Icon mapping — maps domain [MenuIcon] to Material icons.
// ---------------------------------------------------------------------------

IconData _outlinedIcon(MenuIcon icon) => switch (icon) {
      MenuIcon.home => Icons.home_outlined,
      MenuIcon.payments => Icons.swap_horiz_outlined,
      MenuIcon.notifications => Icons.notifications_outlined,
      MenuIcon.accounts => Icons.account_balance_outlined,
      MenuIcon.cards => Icons.credit_card_outlined,
      MenuIcon.settings => Icons.settings_outlined,
      MenuIcon.investments => Icons.trending_up_outlined,
      MenuIcon.insurance => Icons.shield_outlined,
      MenuIcon.loans => Icons.request_quote_outlined,
      MenuIcon.offers => Icons.local_offer_outlined,
    };

IconData _filledIcon(MenuIcon icon) => switch (icon) {
      MenuIcon.home => Icons.home,
      MenuIcon.payments => Icons.swap_horiz,
      MenuIcon.notifications => Icons.notifications,
      MenuIcon.accounts => Icons.account_balance,
      MenuIcon.cards => Icons.credit_card,
      MenuIcon.settings => Icons.settings,
      MenuIcon.investments => Icons.trending_up,
      MenuIcon.insurance => Icons.shield,
      MenuIcon.loans => Icons.request_quote,
      MenuIcon.offers => Icons.local_offer,
    };
