import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';
import '../../widgets/credit_card_widget.dart';
import '../bloc/cards_list_bloc.dart';

/// Page showing the list of user's banking cards.
class CardsListPage extends StatelessWidget {
  const CardsListPage({
    super.key,
    this.onCardTap,
  });

  /// Callback when a card is tapped.
  final void Function(String cardId)? onCardTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mis tarjetas'),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CardsListBloc, CardsListState>(
        builder: (context, state) {
          return switch (state) {
            CardsListInitial() || CardsListLoading() => const Center(
              child: CircularProgressIndicator(
                color: BankingColors.primary,
              ),
            ),
            CardsListError(:final message) => Center(
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
                    onPressed: () {
                      context.read<CardsListBloc>().add(const LoadCards());
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
            CardsListLoaded(:final cards) =>
              cards.isEmpty
                  ? const Center(
                      child: Text(
                        'No tienes tarjetas',
                        style: TextStyle(
                          fontSize: 16,
                          color: BankingColors.onBackgroundLightSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        return CreditCardWidget(
                          card: card,
                          onTap: () => onCardTap?.call(card.id),
                        );
                      },
                    ),
          };
        },
      ),
    );
  }
}
