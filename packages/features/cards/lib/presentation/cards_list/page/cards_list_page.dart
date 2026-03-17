import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.dart';
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
        title: Text(LocaleKeys.cards_list_title.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<CardsListBloc, CardsListState>(
        builder: (context, state) {
          return switch (state.status) {
            CardsListStatus.initial || CardsListStatus.loading => const Center(
              child: CircularProgressIndicator(
                color: BankingColors.primary,
              ),
            ),
            CardsListStatus.error => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: BankingColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(state.errorMessage),
                  const SizedBox(height: 16),
                  BankButton(
                    label: LocaleKeys.common_retry.tr(),
                    onPressed: () {
                      context.read<CardsListBloc>().add(const LoadCards());
                    },
                  ),
                ],
              ),
            ),
            CardsListStatus.loaded =>
              state.cards.isEmpty
                  ? Center(
                      child: Text(
                        LocaleKeys.cards_list_empty.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: BankingColors.onBackgroundLightSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: state.cards.length,
                      itemBuilder: (context, index) {
                        final card = state.cards[index];
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
