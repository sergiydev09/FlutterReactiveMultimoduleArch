import 'dart:async';
import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui/tokens/colors.dart';
import './otp_config.dart';
import './otp_result.dart';

/// A bottom sheet widget that implements the OTP verification flow.
///
/// Displays a 6-digit code input, a countdown timer, and verify/cancel buttons.
/// For development purposes, the code "123456" is always accepted as valid.
class OtpFlowWidget extends StatefulWidget {
  const OtpFlowWidget({
    super.key,
    this.config = const OtpConfig(),
  });

  /// OTP configuration.
  final OtpConfig config;

  @override
  State<OtpFlowWidget> createState() => _OtpFlowWidgetState();
}

class _OtpFlowWidgetState extends State<OtpFlowWidget> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.config.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.config.length,
      (_) => FocusNode(),
    );
    _remainingSeconds = widget.config.expirationSeconds;
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop(OtpResult.expired);
        }
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _enteredCode {
    return _controllers.map((c) => c.text).join();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.config.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {
      _errorMessage = null;
    });
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    final code = _enteredCode;
    if (code.length != widget.config.length) {
      setState(() {
        _errorMessage = LocaleKeys.otp_validation_incomplete.tr();
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    // Simulate verification delay.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Hardcoded valid code for development.
    if (code == '123456') {
      if (mounted) {
        Navigator.of(context).pop(OtpResult.verified);
      }
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = LocaleKeys.otp_validation_incorrect.tr();
      });
    }
  }

  void _cancel() {
    Navigator.of(context).pop(OtpResult.cancelled);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _deliveryLabel() {
    return switch (widget.config.deliveryType) {
      OtpDeliveryType.sms => LocaleKeys.otp_delivery_sms.tr(),
      OtpDeliveryType.email => LocaleKeys.otp_delivery_email.tr(),
      OtpDeliveryType.push => LocaleKeys.otp_delivery_push.tr(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(
            Icons.lock_outline,
            size: 48,
            color: BankingColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKeys.otp_title.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.otp_description.tr(
              namedArgs: {
                'length': widget.config.length.toString(),
                'delivery': _deliveryLabel(),
              },
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // OTP input fields.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.config.length, (index) {
              return Container(
                width: 44,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyDown(index, event),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: BankingColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _onDigitChanged(index, value),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Timer.
          Text(
            LocaleKeys.otp_timer.tr(namedArgs: {'time': _formattedTime}),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _remainingSeconds < 30
                  ? BankingColors.error
                  : Colors.grey.shade600,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: BankingColors.error,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Verify button.
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: BankingColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: BankingColors.primary.withValues(
                  alpha: 0.6,
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      LocaleKeys.otp_verify.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _cancel,
            child: Text(
              LocaleKeys.otp_cancel.tr(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
