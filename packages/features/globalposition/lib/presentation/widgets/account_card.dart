import 'package:common/utils/formatters.dart';
import 'package:domain/entities/account.dart';
import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';

/// A card widget that displays a bank account summary.
class AccountCard extends StatelessWidget {
  const AccountCard({
    required this.account,
    super.key,
    this.onTap,
  });

  /// The account to display.
  final Account account;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BankingColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BankingColors.dividerLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: BankingColors.primary.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForType(account.type),
                color: BankingColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: BankingColors.onBackgroundLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.maskedIban,
                    style: const TextStyle(
                      fontSize: 12,
                      color: BankingColors.onBackgroundLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.formatCurrency(account.balance, currency: account.currency),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: account.balance >= 0
                    ? BankingColors.onBackgroundLight
                    : BankingColors.amountNegative,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(AccountType type) {
    return switch (type) {
      AccountType.current => Icons.account_balance_wallet_outlined,
      AccountType.savings => Icons.savings_outlined,
      AccountType.investment => Icons.trending_up_outlined,
    };
  }
}
