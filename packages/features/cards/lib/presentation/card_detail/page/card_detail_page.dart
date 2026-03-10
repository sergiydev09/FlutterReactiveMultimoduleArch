import 'package:common/generated/locale_keys.g.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';
import '../../cards_list/bloc/cards_list_bloc.dart';
import '../../widgets/credit_card_widget.dart';

/// Page showing the detail of a single card with actions.
class CardDetailPage extends StatelessWidget {
  const CardDetailPage({
    required this.card,
    super.key,
  });

  /// The card to display.
  final CardEntity card;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(LocaleKeys.cards_detail_title.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CardsListBloc, CardsListState>(
        builder: (context, state) {
          // Find the latest version of this card from the state.
          final currentCard = state.status == CardsListStatus.loaded
              ? state.cards.firstWhere(
                  (c) => c.id == card.id,
                  orElse: () => card,
                )
              : card;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                CreditCardWidget(card: currentCard),
                const SizedBox(height: 24),
                // Card information.
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: BankingColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BankingColors.dividerLight),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: LocaleKeys.cards_detail_type.tr(),
                        value: currentCard.isCredit
                            ? LocaleKeys.cards_detail_credit.tr()
                            : LocaleKeys.cards_detail_debit.tr(),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: LocaleKeys.cards_detail_number.tr(),
                        value: currentCard.maskedNumber,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: LocaleKeys.cards_detail_holder.tr(),
                        value: currentCard.cardHolderName,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: LocaleKeys.cards_detail_expiry.tr(),
                        value: currentCard.expiryDate,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: LocaleKeys.cards_detail_status.tr(),
                        value: currentCard.isActive
                            ? LocaleKeys.cards_detail_active.tr()
                            : LocaleKeys.cards_detail_blocked.tr(),
                        valueColor: currentCard.isActive
                            ? BankingColors.success
                            : BankingColors.error,
                      ),
                      if (currentCard.availableLimit != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          label: LocaleKeys.cards_detail_available_limit.tr(),
                          value:
                              '${currentCard.availableLimit!.toStringAsFixed(2)} EUR',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Actions.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<CardsListBloc>().add(
                              ToggleCardStatus(cardId: currentCard.id),
                            );
                          },
                          icon: Icon(
                            currentCard.isActive
                                ? Icons.lock_outline
                                : Icons.lock_open_outlined,
                          ),
                          label: Text(
                            currentCard.isActive
                                ? LocaleKeys.cards_detail_block_action.tr()
                                : LocaleKeys.cards_detail_unblock_action.tr(),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentCard.isActive
                                ? BankingColors.error
                                : BankingColors.success,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // PIN change action.
                          },
                          icon: const Icon(Icons.pin_outlined),
                          label: Text(LocaleKeys.cards_detail_change_pin.tr()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: BankingColors.primary,
                            side: const BorderSide(
                              color: BankingColors.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: BankingColors.onBackgroundLightSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? BankingColors.onBackgroundLight,
          ),
        ),
      ],
    );
  }
}
