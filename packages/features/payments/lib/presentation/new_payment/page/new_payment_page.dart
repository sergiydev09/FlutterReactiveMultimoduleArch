import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.types.dart';
import 'package:ui/tokens/colors.dart';
import '../../../domain/entities/payment.dart';
import '../bloc/new_payment_bloc.dart';

/// Page for creating a new payment/transfer.
///
/// Does NOT include its own Scaffold/AppBar – designed to be hosted
/// inside a shell that provides the app bar, drawer, and bottom nav.
class NewPaymentPage extends StatefulWidget {
  const NewPaymentPage({
    super.key,
    this.sourceAccounts = const [],
  });

  /// List of account display strings for the dropdown.
  /// Format: "Account Name - *1234"
  final List<String> sourceAccounts;

  @override
  State<NewPaymentPage> createState() => _NewPaymentPageState();
}

class _NewPaymentPageState extends State<NewPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final _amountController = TextEditingController();
  final _conceptController = TextEditingController();
  String? _selectedAccount;

  @override
  void initState() {
    super.initState();
    if (widget.sourceAccounts.isNotEmpty) {
      _selectedAccount = widget.sourceAccounts.first;
    }
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final payment = Payment(
        fromAccount: _selectedAccount ?? '',
        toIban: _ibanController.text.trim(),
        amount:
            double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0,
        concept: _conceptController.text.trim(),
      );
      context.read<NewPaymentBloc>().add(SubmitPayment(payment: payment));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source account dropdown.
            Text(
              LocaleKeys.payments_new_source_account.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: BankingColors.onBackgroundLight,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedAccount,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: BankingColors.surfaceLight,
              ),
              items: widget.sourceAccounts
                  .map(
                    (account) => DropdownMenuItem(
                      value: account,
                      child: Text(
                        account,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return LocaleKeys.payments_new_account_required.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // IBAN field.
            Text(
              LocaleKeys.payments_new_iban.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: BankingColors.onBackgroundLight,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _ibanController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'ES00 0000 0000 0000 0000 0000',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: BankingColors.surfaceLight,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.payments_new_iban_required.tr();
                }
                if (value.trim().replaceAll(' ', '').length < 16) {
                  return LocaleKeys.payments_new_iban_invalid.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Amount field.
            Text(
              LocaleKeys.payments_new_amount.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: BankingColors.onBackgroundLight,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              decoration: InputDecoration(
                hintText: '0,00',
                prefixIcon: const Icon(Icons.euro),
                suffixText: 'EUR',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: BankingColors.surfaceLight,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.payments_new_amount_required.tr();
                }
                final amount = double.tryParse(value.replaceAll(',', '.'));
                if (amount == null || amount <= 0) {
                  return LocaleKeys.payments_new_amount_invalid.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Concept field.
            Text(
              LocaleKeys.payments_new_concept.tr(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: BankingColors.onBackgroundLight,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _conceptController,
              maxLength: 140,
              decoration: InputDecoration(
                hintText: LocaleKeys.payments_new_concept_hint.tr(),
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: BankingColors.surfaceLight,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.payments_new_concept_required.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Submit button.
            SizedBox(
              width: double.infinity,
              child: BankButton(
                label: LocaleKeys.payments_new_submit.tr(),
                onPressed: _onSubmit,
                size: BankButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
