import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A styled text input field wrapping [TextFormField].
///
/// Provides a consistent look with label, hint, error, obscure toggle,
/// and optional suffix.
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// Text editing controller.
  final TextEditingController? controller;

  /// Floating label text.
  final String? label;

  /// Placeholder hint text.
  final String? hint;

  /// Error message to display below the input.
  final String? errorText;

  /// Whether to obscure input (for passwords).
  final bool obscureText;

  /// Widget to display at the end of the input field.
  final Widget? suffixIcon;

  /// Widget to display at the start of the input field.
  final Widget? prefixIcon;

  /// The type of keyboard to use.
  final TextInputType? keyboardType;

  /// Action button on the keyboard.
  final TextInputAction? textInputAction;

  /// Called when the input value changes.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the input.
  final ValueChanged<String>? onFieldSubmitted;

  /// Validation function.
  final FormFieldValidator<String>? validator;

  /// Input formatters for restricting / formatting input.
  final List<TextInputFormatter>? inputFormatters;

  /// Number of lines for the input field.
  final int maxLines;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether the field should autofocus.
  final bool autofocus;

  /// Optional focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
