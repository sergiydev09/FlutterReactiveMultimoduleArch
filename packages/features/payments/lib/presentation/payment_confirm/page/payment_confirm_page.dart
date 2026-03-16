import 'package:common/generated/locale_keys.g.dart';
import 'package:common/utils/formatters.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.types.dart';
import 'package:ui/tokens/colors.dart';
import '../../../domain/entities/payment.dart';
import '../../new_payment/bloc/new_payment_bloc.dart';

/// Page showing the payment summary for user confirmation.
class PaymentConfirmPage extends StatelessWidget {
  const PaymentConfirmPage({
    required this.payment,
    super.key,
  });

  /// The payment to confirm.
  final Payment payment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(LocaleKeys.payments_confirm_title.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<NewPaymentBloc, NewPaymentState>(
        builder: (context, state) {
          final isProcessing = state.status == NewPaymentStatus.processing;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Amount display.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: BankingColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BankingColors.dividerLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                LocaleKeys.payments_confirm_amount_label.tr(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color:
                                      BankingColors.onBackgroundLightSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Formatters.formatCurrency(payment.amount),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: BankingColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Details.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: BankingColors.surfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: BankingColors.dividerLight,
                            ),
                          ),
                          child: Column(
                            children: [
                              _SummaryRow(
                                label: LocaleKeys.payments_confirm_source_account.tr(),
                                value: payment.fromAccount,
                              ),
                              const Divider(height: 24),
                              _SummaryRow(
                                label: LocaleKeys.payments_confirm_iban.tr(),
                                value: Formatters.formatIban(payment.toIban),
                              ),
                              const Divider(height: 24),
                              _SummaryRow(
                                label: LocaleKeys.payments_confirm_concept.tr(),
                                value: payment.concept,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Confirm button.
                SizedBox(
                  width: double.infinity,
                  child: BankButton(
                    label: LocaleKeys.payments_confirm_submit.tr(),
                    isLoading: isProcessing,
                    onPressed: isProcessing
                        ? null
                        : () {
                            context.read<NewPaymentBloc>().add(
                              const ConfirmPayment(),
                            );
                          },
                    size: BankButtonSize.large,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: BankButton(
                    label: LocaleKeys.payments_confirm_cancel.tr(),
                    type: BankButtonType.outlined,
                    onPressed: isProcessing ? null : () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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
          width: 110,
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
