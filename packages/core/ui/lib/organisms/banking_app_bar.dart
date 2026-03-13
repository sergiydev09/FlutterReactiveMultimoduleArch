import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../tokens/typography.dart';
import '../utils/preview_wrapper.dart';

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

// --- Previews ---

  @Preview(
    name: 'Standard App Bar',
    group: 'BankingAppBar',
    wrapper: appPreviewWrapper,
  )
  static Widget standardPreview() => const BankingAppBar(
        title: 'Transactions',
      );

  @Preview(
    name: 'App Bar with Actions',
    group: 'BankingAppBar',
    wrapper: appPreviewWrapper,
  )
  static Widget actionsPreview() => BankingAppBar(
        title: 'Home',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {},
          ),
        ],
      );

  @Preview(
    name: 'Colored Background App Bar',
    group: 'BankingAppBar',
    wrapper: appPreviewWrapper,
  )
  static Widget coloredPreview() => BankingAppBar(
        title: 'Summary',
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {},
          ),
        ],
      );
}
