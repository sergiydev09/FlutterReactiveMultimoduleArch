import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.dart';
import 'package:ui/atoms/buttons/bank_button/bank_button.types.dart';
import 'package:ui/tokens/colors.dart';

/// Page for initiating the password recovery flow.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _dniController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(LocaleKeys.forgot_password_title.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _submitted ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            LocaleKeys.forgot_password_headline.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: BankingColors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.forgot_password_description.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: BankingColors.onBackgroundLightSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _dniController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSubmit(),
            decoration: InputDecoration(
              labelText: LocaleKeys.login_dni_label.tr(),
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: BankingColors.surfaceLight,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return LocaleKeys.login_dni_required.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: BankButton(
              label: LocaleKeys.forgot_password_submit.tr(),
              onPressed: _onSubmit,
              size: BankButtonSize.large,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: BankingColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: BankingColors.success,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          LocaleKeys.forgot_password_success_title.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          LocaleKeys.forgot_password_success_message.tr(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: BankingColors.onBackgroundLightSecondary,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: BankButton(
            label: LocaleKeys.forgot_password_back.tr(),
            type: BankButtonType.outlined,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}
