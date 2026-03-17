import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.types.dart';
import 'package:ui/tokens/colors.dart';

/// Page showing the result of a payment (success or error).
class PaymentResultPage extends StatelessWidget {
  const PaymentResultPage({
    required this.isSuccess,
    super.key,
    this.confirmationId,
    this.errorMessage,
    this.onDone,
    this.onRetry,
  });

  /// Whether the payment was successful.
  final bool isSuccess;

  /// Confirmation ID for successful payments.
  final String? confirmationId;

  /// Error message for failed payments.
  final String? errorMessage;

  /// Callback for the "Done" button.
  final VoidCallback? onDone;

  /// Callback for the "Retry" button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Status icon.
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color:
                      (isSuccess ? BankingColors.success : BankingColors.error)
                          .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  size: 56,
                  color: isSuccess
                      ? BankingColors.success
                      : BankingColors.error,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isSuccess
                    ? LocaleKeys.payments_result_success_title.tr()
                    : LocaleKeys.payments_result_error_title.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: BankingColors.onBackgroundLight,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isSuccess
                    ? LocaleKeys.payments_result_success_message.tr()
                    : errorMessage ??
                          LocaleKeys.payments_result_error_message.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: BankingColors.onBackgroundLightSecondary,
                ),
              ),
              if (isSuccess && confirmationId != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BankingColors.surfaceVariantLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.payments_result_reference_label.tr(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: BankingColors.onBackgroundLightSecondary,
                        ),
                      ),
                      Text(
                        confirmationId!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: BankingColors.onBackgroundLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Action buttons.
              if (isSuccess) ...[
                SizedBox(
                  width: double.infinity,
                  child: BankButton(
                    label: LocaleKeys.payments_result_go_home.tr(),
                    onPressed: onDone,
                    size: BankButtonSize.large,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: BankButton(
                    label: LocaleKeys.payments_result_retry.tr(),
                    onPressed: onRetry,
                    size: BankButtonSize.large,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: BankButton(
                    label: LocaleKeys.payments_result_cancel.tr(),
                    type: BankButtonType.outlined,
                    onPressed: onDone,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
