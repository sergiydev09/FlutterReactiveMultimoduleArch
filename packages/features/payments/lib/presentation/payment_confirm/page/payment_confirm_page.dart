import 'package:common/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: const Text('Confirmar transferencia'),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<NewPaymentBloc, NewPaymentState>(
        builder: (context, state) {
          final isProcessing = state is NewPaymentProcessing;

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
                              const Text(
                                'Importe',
                                style: TextStyle(
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
                                label: 'Cuenta origen',
                                value: payment.fromAccount,
                              ),
                              const Divider(height: 24),
                              _SummaryRow(
                                label: 'IBAN destino',
                                value: Formatters.formatIban(payment.toIban),
                              ),
                              const Divider(height: 24),
                              _SummaryRow(
                                label: 'Concepto',
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
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            context.read<NewPaymentBloc>().add(
                              const ConfirmPayment(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BankingColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Confirmar transferencia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: isProcessing
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BankingColors.primary,
                      side: const BorderSide(color: BankingColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
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
