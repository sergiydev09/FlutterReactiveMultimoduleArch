import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';

/// A row of quick action buttons for the home screen.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onTransfer,
    this.onPay,
    this.onBizum,
    this.onCards,
  });

  /// Callback when the "Transferir" action is tapped.
  final VoidCallback? onTransfer;

  /// Callback when the "Pagar" action is tapped.
  final VoidCallback? onPay;

  /// Callback when the "Bizum" action is tapped.
  final VoidCallback? onBizum;

  /// Callback when the "Tarjetas" action is tapped.
  final VoidCallback? onCards;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _QuickActionItem(
          icon: Icons.swap_horiz,
          label: LocaleKeys.quick_actions_transfer.tr(),
          onTap: onTransfer,
        ),
        _QuickActionItem(
          icon: Icons.payment,
          label: LocaleKeys.quick_actions_pay.tr(),
          onTap: onPay,
        ),
        _QuickActionItem(
          icon: Icons.flash_on,
          label: LocaleKeys.quick_actions_bizum.tr(),
          onTap: onBizum,
        ),
        _QuickActionItem(
          icon: Icons.credit_card,
          label: LocaleKeys.quick_actions_cards.tr(),
          onTap: onCards,
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: BankingColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: BankingColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: BankingColors.onBackgroundLight,
            ),
          ),
        ],
      ),
    );
  }
}
