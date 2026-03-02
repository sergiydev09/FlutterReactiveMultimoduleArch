import 'package:flutter/material.dart';

import 'package:ui/tokens/spacing.dart';
import 'package:ui/tokens/typography.dart';

/// Button variant types.
enum AppButtonVariant {
  /// Filled primary button.
  primary,

  /// Filled secondary button.
  secondary,

  /// Outlined button.
  outline,
}

/// A configurable button widget that supports multiple visual variants
/// and a built-in loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  });

  /// Button label text.
  final String label;

  /// Callback when the button is tapped. Disabled when `null` or [isLoading].
  final VoidCallback? onPressed;

  /// Visual style variant.
  final AppButtonVariant variant;

  /// Whether to show a loading indicator instead of the label.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button should stretch to fill available width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveOnPressed = isLoading ? null : onPressed;

    final child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.outline
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary,
              ),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: BankingSpacing.sm),
              ],
              Text(label, style: BankingTypography.labelLarge),
            ],
          );

    final minimumSize = fullWidth
        ? const Size(double.infinity, 52)
        : const Size(0, 52);

    return switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: child,
      ),
      AppButtonVariant.secondary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: theme.colorScheme.primary),
        ),
        child: child,
      ),
    };
  }
}
