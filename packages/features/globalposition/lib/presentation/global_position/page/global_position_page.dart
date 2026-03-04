import 'package:common/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promotions/domain/promo_banner.dart';
import 'package:promotions/presentation/promo_carousel.dart';
import 'package:ui/tokens/colors.dart';
import '../../widgets/account_card.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/transaction_tile.dart';
import '../bloc/global_position_bloc.dart';

/// The main home screen showing the user's global financial position.
///
/// Does NOT include its own Scaffold/AppBar – designed to be hosted
/// inside a shell that provides the app bar, drawer, and bottom nav.
class GlobalPositionPage extends StatelessWidget {
  const GlobalPositionPage({
    super.key,
    this.promoBanners = const [],
    this.onAccountTap,
    this.onTransactionTap,
    this.onTransfer,
    this.onPay,
    this.onBizum,
    this.onCards,
    this.onPromoBannerTap,
  });

  /// Promotional banners to display in the carousel.
  final List<PromoBanner> promoBanners;

  /// Callback when an account card is tapped.
  final void Function(String accountId)? onAccountTap;

  /// Callback when a transaction is tapped.
  final void Function(String transactionId)? onTransactionTap;

  /// Callback for quick action buttons.
  final VoidCallback? onTransfer;
  final VoidCallback? onPay;
  final VoidCallback? onBizum;
  final VoidCallback? onCards;

  /// Callback when a promo banner is tapped.
  final void Function(PromoBanner banner)? onPromoBannerTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalPositionBloc, GlobalPositionState>(
      builder: (context, state) {
        return switch (state) {
          GPInitial() || GPLoading() => const Center(
            child: CircularProgressIndicator(
              color: BankingColors.primary,
            ),
          ),
          GPError(:final message) => _buildError(context, message),
          GPLoaded() => _buildLoaded(context, state),
        };
      },
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: BankingColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: BankingColors.onBackgroundLightSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<GlobalPositionBloc>().add(
                  const LoadGlobalPosition(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BankingColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, GPLoaded state) {
    return RefreshIndicator(
      color: BankingColors.primary,
      onRefresh: () async {
        context.read<GlobalPositionBloc>().add(const RefreshGlobalPosition());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Total balance card.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TotalBalanceCard(totalBalance: state.totalBalance),
            ),
            const SizedBox(height: 24),
            // Quick actions.
            QuickActions(
              onTransfer: onTransfer,
              onPay: onPay,
              onBizum: onBizum,
              onCards: onCards,
            ),
            const SizedBox(height: 24),
            // Accounts section.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Mis cuentas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BankingColors.onBackgroundLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...state.accounts.map(
              (account) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: AccountCard(
                  account: account,
                  onTap: () => onAccountTap?.call(account.id),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Recent transactions section.
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Últimos movimientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: BankingColors.onBackgroundLight,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (state.transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay movimientos recientes',
                  style: TextStyle(
                    color: BankingColors.onBackgroundLightSecondary,
                  ),
                ),
              )
            else
              ...state.transactions.map(
                (tx) => TransactionTile(
                  transaction: tx,
                  onTap: () => onTransactionTap?.call(tx.id),
                ),
              ),
            const SizedBox(height: 24),
            // Promotional carousel.
            if (promoBanners.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Promociones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: BankingColors.onBackgroundLight,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PromoCarousel(
                banners: promoBanners,
                onBannerTap: onPromoBannerTap,
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TotalBalanceCard extends StatelessWidget {
  const _TotalBalanceCard({required this.totalBalance});

  final double totalBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BankingColors.primary,
            BankingColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BankingColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo total',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(totalBalance),
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
}
