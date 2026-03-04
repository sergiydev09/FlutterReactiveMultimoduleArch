import 'dart:async';
import 'package:accounts/routing/accounts_routes.dart';
import 'package:cards/routing/cards_routes.dart';
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

  String _titleForLocation(String location) {
    if (location.startsWith(GlobalPositionRoutes.home)) return 'Inicio';
    if (location.startsWith(PaymentRoutes.base)) return 'Pagos';
    if (location.startsWith(NotificationRoutes.notifications)) return 'Avisos';
    return 'BankApp';
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
        title: Text(_titleForLocation(location)),
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
                userName.isNotEmpty ? userName : 'Usuario',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              accountEmail: const Text('cliente@bankapp.es'),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_outlined),
              title: const Text('Cuentas'),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(AccountRoutes.accounts));
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: const Text('Tarjetas'),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(CardRoutes.cards));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Ajustes'),
              onTap: () {
                Navigator.pop(context);
                unawaited(context.push(SettingsRoutes.settings));
              },
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.trending_up_outlined, color: Colors.grey),
              title: Text('Inversiones', style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                'Proximamente',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.shield_outlined, color: Colors.grey),
              title: Text('Seguros', style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                'Proximamente',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.request_quote_outlined, color: Colors.grey),
              title: Text('Prestamos', style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                'Proximamente',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.local_offer_outlined, color: Colors.grey),
              title: Text('Ofertas', style: TextStyle(color: Colors.grey)),
              subtitle: Text(
                'Proximamente',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  label: const Text('Cerrar sesion'),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Pagos',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Avisos',
          ),
        ],
      ),
    );
  }
}
