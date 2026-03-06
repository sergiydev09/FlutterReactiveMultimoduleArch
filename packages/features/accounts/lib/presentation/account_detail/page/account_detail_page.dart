import 'package:common/utils/formatters.dart';
import 'package:domain/entities/transaction.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';
import '../../account_transactions/bloc/account_transactions_bloc.dart';
import '../../widgets/account_info_header.dart';
import '../bloc/account_detail_bloc.dart';

/// Page showing the detail of a single account with its transactions.
class AccountDetailPage extends StatelessWidget {
  const AccountDetailPage({
    super.key,
    this.onTransactionTap,
  });

  /// Callback when a transaction is tapped.
  final void Function(Transaction transaction)? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      body: BlocBuilder<AccountDetailBloc, AccountDetailState>(
        builder: (context, detailState) {
          return switch (detailState) {
            AccountDetailInitial() || AccountDetailLoading() => const Center(
              child: CircularProgressIndicator(
                color: BankingColors.primary,
              ),
            ),
            AccountDetailError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: BankingColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('common.back'.tr()),
                  ),
                ],
              ),
            ),
            AccountDetailLoaded(:final account) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: BankingColors.primary,
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: AccountInfoHeader(account: account),
                  ),
                  title: Text(
                    account.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Transactions list.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Text(
                      'accounts.detail.transactions_section'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                BlocBuilder<AccountTransactionsBloc, AccountTransactionsState>(
                  builder: (context, txState) {
                    return switch (txState) {
                      AccountTransactionsInitial() ||
                      AccountTransactionsLoading() => const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: BankingColors.primary,
                          ),
                        ),
                      ),
                      AccountTransactionsError(:final message) =>
                        SliverFillRemaining(
                          child: Center(child: Text(message)),
                        ),
                      AccountTransactionsLoaded(
                        :final transactions,
                        :final hasReachedMax,
                      ) =>
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= transactions.length) {
                                if (!hasReachedMax) {
                                  context.read<AccountTransactionsBloc>().add(
                                    const LoadMoreTransactions(),
                                  );
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: BankingColors.primary,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              }

                              final tx = transactions[index];
                              return _TransactionListItem(
                                transaction: tx,
                                onTap: () => onTransactionTap?.call(tx),
                              );
                            },
                            childCount:
                                transactions.length + (hasReachedMax ? 0 : 1),
                          ),
                        ),
                    };
                  },
                ),
              ],
            ),
          };
        },
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor:
            (transaction.isIncome
                    ? BankingColors.amountPositive
                    : BankingColors.amountNegative)
                .withValues(alpha: 0.1),
        child: Icon(
          transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: transaction.isIncome
              ? BankingColors.amountPositive
              : BankingColors.amountNegative,
          size: 18,
        ),
      ),
      title: Text(
        transaction.description,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        Formatters.formatDate(transaction.createdAt),
        style: const TextStyle(
          fontSize: 12,
          color: BankingColors.onBackgroundLightSecondary,
        ),
      ),
      trailing: Text(
        Formatters.formatSignedCurrency(
          transaction.amount,
          currency: transaction.currency,
        ),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: transaction.isIncome
              ? BankingColors.amountPositive
              : BankingColors.amountNegative,
        ),
      ),
    );
  }
}
