import 'package:common/config/environment.dart';
import 'package:common/generated/locale_keys.g.dart';
import 'package:domain/entities/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ui/tokens/colors.dart';
import '../../widgets/environment_selector.dart';
import '../bloc/login_bloc.dart';

/// The login page for the banking application.
///
/// Provides fields for DNI and password, along with biometric
/// login and forgot password options.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.showEnvironmentSelector = false,
    this.isBiometricEnabled = false,
    this.onForgotPassword,
    this.onLoginSuccess,
    this.onEnvironmentChanged,
  });

  /// Whether to show the environment selector (MOCK/PRE/PRO).
  final bool showEnvironmentSelector;

  /// Whether to show the biometric login button.
  final bool isBiometricEnabled;

  /// Callback when the user taps "Forgot password".
  final VoidCallback? onForgotPassword;

  /// Callback when login is successful, providing the authenticated [User].
  final ValueChanged<User>? onLoginSuccess;

  /// Callback when the user selects a different environment.
  final ValueChanged<Environment>? onEnvironmentChanged;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(
        LoginRequested(
          dni: _dniController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // dark icons on Android
        statusBarBrightness: Brightness.light, // light bar (dark icons) on iOS
      ),
      child: Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.authenticated) {
            widget.onLoginSuccess?.call(state.user!);
          } else if (state.status == LoginStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: BankingColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / branding.
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: BankingColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      LocaleKeys.app_name.tr(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: BankingColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocaleKeys.login_subtitle.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BankingColors.onBackgroundLightSecondary,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // DNI field.
                    TextFormField(
                      controller: _dniController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 16),
                    // Password field.
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
                      decoration: InputDecoration(
                        labelText: LocaleKeys.login_password_label.tr(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: BankingColors.surfaceLight,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocaleKeys.login_password_required.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Forgot password.
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: widget.onForgotPassword,
                        child: Text(
                          LocaleKeys.login_forgot_password.tr(),
                          style: const TextStyle(
                            color: BankingColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login button.
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        final isLoading = state.status == LoginStatus.loading;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BankingColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: isLoading
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
                                : Text(
                                    LocaleKeys.login_submit.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    if (widget.isBiometricEnabled) ...[
                      const SizedBox(height: 16),
                      // Biometric login.
                      OutlinedButton.icon(
                        onPressed: () {
                          context.read<LoginBloc>().add(
                            const BiometricLoginRequested(),
                          );
                        },
                        icon: const Icon(Icons.fingerprint),
                        label: Text(LocaleKeys.login_biometric.tr()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: BankingColors.primary,
                          side: const BorderSide(color: BankingColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                    if (widget.showEnvironmentSelector) ...[
                      const SizedBox(height: 32),
                      EnvironmentSelector(
                        onChanged: (env) {
                          widget.onEnvironmentChanged?.call(env);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
