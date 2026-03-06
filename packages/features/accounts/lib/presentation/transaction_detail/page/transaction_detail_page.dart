import 'package:common/utils/formatters.dart';
import 'package:domain/entities/transaction.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';

/// Page showing the full details of a single transaction.
class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({
    required this.transaction,
    super.key,
  });

  /// The transaction to display.
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text('transactions.detail.title'.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Amount header.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              color: BankingColors.primary,
              child: Column(
                children: [
                  Icon(
                    transaction.isIncome
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatSignedCurrency(
                      transaction.amount,
                      currency: transaction.currency,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(
                        transaction.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(transaction.status),
                      style: TextStyle(
                        color: _statusColor(transaction.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Details card.
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BankingColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BankingColors.dividerLight),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'transactions.detail.concept'.tr(),
                    value: transaction.description,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'transactions.detail.date'.tr(),
                    value: Formatters.formatDateTime(transaction.createdAt),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'transactions.detail.category'.tr(),
                    value: _categoryLabel(transaction.category),
                  ),
                  if (transaction.merchant != null) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      label: 'transactions.detail.merchant'.tr(),
                      value: transaction.merchant!,
                    ),
                  ],
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'transactions.detail.reference'.tr(),
                    value: transaction.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.completed => Colors.green,
      TransactionStatus.pending => Colors.orange,
      TransactionStatus.failed => Colors.red,
      TransactionStatus.cancelled => Colors.grey,
    };
  }

  String _statusLabel(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.completed => 'transactions.status.completed'.tr(),
      TransactionStatus.pending => 'transactions.status.pending'.tr(),
      TransactionStatus.failed => 'transactions.status.failed'.tr(),
      TransactionStatus.cancelled => 'transactions.status.cancelled'.tr(),
    };
  }

  String _categoryLabel(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.salary => 'transactions.category.salary'.tr(),
      TransactionCategory.transfer => 'transactions.category.transfer'.tr(),
      TransactionCategory.shopping => 'transactions.category.shopping'.tr(),
      TransactionCategory.food => 'transactions.category.food'.tr(),
      TransactionCategory.transport => 'transactions.category.transport'.tr(),
      TransactionCategory.entertainment =>
        'transactions.category.entertainment'.tr(),
      TransactionCategory.bills => 'transactions.category.bills'.tr(),
      TransactionCategory.health => 'transactions.category.health'.tr(),
      TransactionCategory.atm => 'transactions.category.atm'.tr(),
      TransactionCategory.other => 'transactions.category.other'.tr(),
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: BankingColors.onBackgroundLightSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: BankingColors.onBackgroundLight,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
