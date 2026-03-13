import 'package:common/generated/locale_keys.g.dart';
import 'package:common/utils/formatters.dart';
import 'package:domain/entities/account.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/tokens/colors.dart';
import '../../../routing/accounts_routes.dart';
import '../bloc/accounts_list_bloc.dart';

/// Page that displays all accounts for the current user.
class AccountsListPage extends StatelessWidget {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(LocaleKeys.accounts_list_title.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<AccountsListBloc, AccountsListState>(
        builder: (context, state) {
          return switch (state.status) {
            AccountsListStatus.initial || AccountsListStatus.loading =>
              const Center(
                child: CircularProgressIndicator(
                  color: BankingColors.primary,
                ),
              ),
            AccountsListStatus.error => Center(
              child: Text(state.errorMessage),
            ),
            AccountsListStatus.loaded => ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: state.accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return _AccountListTile(
                  account: account,
                  onTap: () => context.pushNamed(
                    AccountRoutes.accountDetail,
                    pathParameters: {'id': account.id},
                    extra: account.name,
                  ),
                );
              },
            ),
          };
        },
      ),
    );
  }
}

class _AccountListTile extends StatelessWidget {
  const _AccountListTile({required this.account, this.onTap});

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: BankingColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BankingColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: BankingColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: BankingColors.onBackgroundLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.iban,
                        style: const TextStyle(
                          fontSize: 12,
                          color: BankingColors.onBackgroundLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  Formatters.formatCurrency(account.balance),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BankingColors.onBackgroundLight,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  color: BankingColors.onBackgroundLightSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
