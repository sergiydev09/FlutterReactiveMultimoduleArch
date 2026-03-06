import 'dart:async';
import 'package:accounts/routing/accounts_routes.dart';
import 'package:cards/routing/cards_routes.dart';
import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:globalposition/routing/globalposition_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:notifications_feature/routing/notifications_routes.dart';
import 'package:payments/routing/payments_routes.dart';
import 'package:settings/routing/settings_routes.dart';
import 'package:ui/tokens/colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.child,
    this.userName = '',
    this.onLogout,
    super.key,
  });

  final Widget child;
  final String userName;
  final VoidCallback? onLogout;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(GlobalPositionRoutes.home)) return 0;
    if (location.startsWith(PaymentRoutes.base)) return 1;
    if (location.startsWith(NotificationRoutes.notifications)) return 2;
    return 0;
  }

  String _titleForLocation(BuildContext context, String location) {
    if (location.startsWith(GlobalPositionRoutes.home)) {
      return LocaleKeys.nav_home.tr();
    }
    if (location.startsWith(PaymentRoutes.base)) return LocaleKeys.nav_payments.tr();
    if (location.startsWith(NotificationRoutes.notifications)) {
      return LocaleKeys.nav_notifications.tr();
    }
    return LocaleKeys.app_name.tr();
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(_titleForLocation(context, location)),
        actions: [
          if (location.startsWith(GlobalPositionRoutes.home))
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.go(NotificationRoutes.notifications),
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: BankingColors.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _initials(userName),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: BankingColors.primary,
                  ),
                ),
              ),
              accountName: Text(
                userName.isNotEmpty ? userName : LocaleKeys.shell_default_user.tr(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              accountEmail: Text(LocaleKeys.shell_default_email.tr()),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: Text(LocaleKeys.shell_drawer_accounts.tr()),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(AccountRoutes.accounts));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: Text(LocaleKeys.shell_drawer_cards.tr()),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(CardRoutes.cards));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(LocaleKeys.shell_drawer_settings.tr()),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(SettingsRoutes.settings));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.trending_up_outlined, color: Colors.grey),
              title: Text(
                LocaleKeys.shell_drawer_investments.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                LocaleKeys.shell_drawer_coming_soon.tr(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: Colors.grey),
              title: Text(
                LocaleKeys.shell_drawer_insurance.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                LocaleKeys.shell_drawer_coming_soon.tr(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.request_quote_outlined, color: Colors.grey),
              title: Text(
                LocaleKeys.shell_drawer_loans.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                LocaleKeys.shell_drawer_coming_soon.tr(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            ListTile(
              leading: const Icon(Icons.local_offer_outlined, color: Colors.grey),
              title: Text(
                LocaleKeys.shell_drawer_offers.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              subtitle: Text(
                LocaleKeys.shell_drawer_coming_soon.tr(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout != null
                      ? () {
                          Navigator.pop(context);
                          onLogout!();
                        }
                      : null,
                  icon: const Icon(Icons.logout),
                  label: Text(LocaleKeys.common_logout.tr()),
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
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(GlobalPositionRoutes.home);
            case 1:
              context.go(PaymentRoutes.newPayment);
            case 2:
              context.go(NotificationRoutes.notifications);
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: LocaleKeys.nav_home.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: LocaleKeys.nav_payments.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: LocaleKeys.nav_notifications.tr(),
          ),
        ],
      ),
    );
  }
}
