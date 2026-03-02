import 'package:flutter/material.dart';

import 'package:ui/tokens/typography.dart';

/// A styled app bar consistent with the banking design system.
///
/// Supports a title, optional back button, and trailing action widgets.
class BankingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BankingAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.elevation = 0,
    this.backgroundColor,
    this.centerTitle = true,
  });

  /// The title displayed in the center of the app bar.
  final String? title;

  /// Whether to display the back button.
  final bool showBackButton;

  /// Optional trailing action widgets.
  final List<Widget>? actions;

  /// Custom back-button callback. Defaults to `Navigator.pop`.
  final VoidCallback? onBackPressed;

  /// Elevation of the app bar.
  final double elevation;

  /// Background color override.
  final Color? backgroundColor;

  /// Whether the title should be centered.
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: elevation,
      scrolledUnderElevation: 1,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: BankingTypography.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            )
          : null,
      actions: actions,
    );
  }
}
