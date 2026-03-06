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
        title: Text('cards.detail.title'.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CardsListBloc, CardsListState>(
        builder: (context, state) {
          // Find the latest version of this card from the state.
          final currentCard = state is CardsListLoaded
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
                        label: 'cards.detail.type'.tr(),
                        value: currentCard.isCredit
                            ? 'cards.detail.credit'.tr()
                            : 'cards.detail.debit'.tr(),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'cards.detail.number'.tr(),
                        value: currentCard.maskedNumber,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'cards.detail.holder'.tr(),
                        value: currentCard.cardHolderName,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'cards.detail.expiry'.tr(),
                        value: currentCard.expiryDate,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'cards.detail.status'.tr(),
                        value: currentCard.isActive
                            ? 'cards.detail.active'.tr()
                            : 'cards.detail.blocked'.tr(),
                        valueColor: currentCard.isActive
                            ? BankingColors.success
                            : BankingColors.error,
                      ),
                      if (currentCard.availableLimit != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'cards.detail.available_limit'.tr(),
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
                                ? 'cards.detail.block_action'.tr()
                                : 'cards.detail.unblock_action'.tr(),
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
                          label: Text('cards.detail.change_pin'.tr()),
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
