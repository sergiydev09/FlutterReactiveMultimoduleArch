import 'package:cards/presentation/cards_list/cards_bloc.dart';
import 'package:cards/presentation/widgets/credit_card_widget.dart';
import 'package:domain/entities/card_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';

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
        title: const Text('Detalle de tarjeta'),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CardsBloc, CardsState>(
        builder: (context, state) {
          // Find the latest version of this card from the state.
          final currentCard = state is CardsLoaded
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
                        label: 'Tipo',
                        value: currentCard.isCredit
                            ? 'Tarjeta de Crédito'
                            : 'Tarjeta de Débito',
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Número',
                        value: currentCard.maskedNumber,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Titular',
                        value: currentCard.cardHolderName,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Caducidad',
                        value: currentCard.expiryDate,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        label: 'Estado',
                        value: currentCard.isActive ? 'Activa' : 'Bloqueada',
                        valueColor: currentCard.isActive
                            ? BankingColors.success
                            : BankingColors.error,
                      ),
                      if (currentCard.availableLimit != null) ...[
                        const Divider(height: 24),
                        _InfoRow(
                          label: 'Límite disponible',
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
                            context.read<CardsBloc>().add(
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
                                ? 'Bloquear tarjeta'
                                : 'Desbloquear tarjeta',
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
                          label: const Text('Cambiar PIN'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: BankingColors.primary,
                            side:
                                const BorderSide(color: BankingColors.primary),
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
