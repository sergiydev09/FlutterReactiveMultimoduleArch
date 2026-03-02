import 'package:common/utils/formatters.dart';
import 'package:domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';

/// A list tile widget that displays a single transaction.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    super.key,
    this.onTap,
  });

  /// The transaction to display.
  final Transaction transaction;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isIncome
                        ? BankingColors.amountPositive
                        : BankingColors.amountNegative)
                    .withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForCategory(transaction.category),
                color: isIncome
                    ? BankingColors.amountPositive
                    : BankingColors.amountNegative,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: BankingColors.onBackgroundLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatRelativeTime(transaction.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: BankingColors.onBackgroundLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Formatters.formatSignedCurrency(
                transaction.amount,
                currency: transaction.currency,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isIncome
                    ? BankingColors.amountPositive
                    : BankingColors.amountNegative,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.salary => Icons.work_outline,
      TransactionCategory.transfer => Icons.swap_horiz,
      TransactionCategory.shopping => Icons.shopping_bag_outlined,
      TransactionCategory.food => Icons.restaurant_outlined,
      TransactionCategory.transport => Icons.directions_car_outlined,
      TransactionCategory.entertainment => Icons.movie_outlined,
      TransactionCategory.bills => Icons.receipt_long_outlined,
      TransactionCategory.health => Icons.medical_services_outlined,
      TransactionCategory.atm => Icons.atm_outlined,
      TransactionCategory.other => Icons.more_horiz,
    };
  }
}
