import 'package:common/utils/formatters.dart';
import 'package:domain/entities/account.dart';
import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';

/// Header widget showing detailed account information (IBAN, balance, type).
class AccountInfoHeader extends StatelessWidget {
  const AccountInfoHeader({
    required this.account,
    super.key,
  });

  /// The account to display.
  final Account account;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BankingColors.primary,
            BankingColors.primaryDark,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _accountTypeLabel(account.type),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (account.isMain) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BankingColors.accent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Principal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            account.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatIban(account.iban),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Saldo disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(
              account.balance,
              currency: account.currency,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _accountTypeLabel(AccountType type) {
    return switch (type) {
      AccountType.current => 'Cuenta Corriente',
      AccountType.savings => 'Cuenta Ahorro',
      AccountType.investment => 'Inversión',
    };
  }
}
