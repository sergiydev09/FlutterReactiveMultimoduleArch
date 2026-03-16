import 'package:flutter/material.dart';

import '../../../tokens/colors.dart';
import '../../../tokens/radii.dart';
import '../../../tokens/spacing.dart';
import '../../../tokens/typography.dart';
import 'bank_button.types.dart';

part 'bank_button_styles.dart';
part 'bank_button_variants.dart';

/// A multi-variant button component from the Banking design system.
///
/// Supports six [BankButtonType]s and three [BankButtonSize]s.
/// Setting [onPressed] to `null` disables the button — idiomatic Flutter,
/// no extra `isDisabled` prop needed.
/// Setting [isLoading] to `true` replaces content with a spinner and
/// disables taps.
///
/// [icon] is **required** for [BankButtonType.ghost], [BankButtonType.icon],
/// and [BankButtonType.nestedIcon] — enforced via assert.
class BankButton extends StatelessWidget {
  const BankButton({
    required this.label,
    super.key,
    this.type = BankButtonType.solid,
    this.size = BankButtonSize.medium,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  }) : assert(
         !(type == BankButtonType.ghost ||
               type == BankButtonType.icon ||
               type == BankButtonType.nestedIcon) ||
             icon != null,
         'BankButton: icon is required for ghost, icon, and nestedIcon types.',
       );

  /// Text label. Also used as the accessibility label for icon-only buttons.
  final String label;

  /// Visual type — determines shape, colour, and content layout.
  final BankButtonType type;

  /// Size variant — controls height, padding, and icon size.
  final BankButtonSize size;

  /// Tap callback. `null` renders the button disabled.
  final VoidCallback? onPressed;

  /// Leading icon. Required for [BankButtonType.ghost],
  /// [BankButtonType.icon], and [BankButtonType.nestedIcon].
  final IconData? icon;

  /// Replaces content with a [CircularProgressIndicator] and disables taps.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _LoadingButton(type: type, size: size);
    }

    return switch (type) {
      BankButtonType.solid => _SolidButton(
        label: label,
        size: size,
        onPressed: onPressed,
      ),
      BankButtonType.outlined => _OutlinedButton(
        label: label,
        size: size,
        onPressed: onPressed,
      ),
      BankButtonType.subtle => _SubtleButton(
        label: label,
        size: size,
        onPressed: onPressed,
      ),
      BankButtonType.ghost => _GhostButton(
        label: label,
        size: size,
        onPressed: onPressed,
        icon: icon!,
      ),
      BankButtonType.icon => _IconButton(
        label: label,
        size: size,
        onPressed: onPressed,
        icon: icon!,
      ),
      BankButtonType.nestedIcon => _NestedIconButton(
        label: label,
        size: size,
        onPressed: onPressed,
        icon: icon!,
      ),
    };
  }
}
