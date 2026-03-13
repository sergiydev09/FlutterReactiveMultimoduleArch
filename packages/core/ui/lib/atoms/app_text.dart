import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../tokens/typography.dart';
import '../utils/preview_wrapper.dart';

/// Predefined text style variants.
enum AppTextVariant {
  /// 32/40 Bold.
  headlineLarge,

  /// 28/36 Bold.
  headlineMedium,

  /// 22/28 SemiBold.
  titleLarge,

  /// 18/24 SemiBold.
  titleMedium,

  /// 16/24 Regular.
  bodyLarge,

  /// 14/20 Regular.
  bodyMedium,

  /// 14/20 Medium.
  labelLarge,

  /// 11/16 Medium.
  labelSmall,
}

/// A convenience text widget that selects the correct [TextStyle] from
/// the design system based on the specified [variant].
class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  /// The text to display.
  final String text;

  /// The typographic style to apply.
  final AppTextVariant variant;

  /// Optional override color.
  final Color? color;

  /// Maximum number of lines.
  final int? maxLines;

  /// How visual overflow is handled.
  final TextOverflow? overflow;

  /// Text alignment.
  final TextAlign? textAlign;

  TextStyle get _baseStyle => switch (variant) {
    AppTextVariant.headlineLarge => BankingTypography.headlineLarge,
    AppTextVariant.headlineMedium => BankingTypography.headlineMedium,
    AppTextVariant.titleLarge => BankingTypography.titleLarge,
    AppTextVariant.titleMedium => BankingTypography.titleMedium,
    AppTextVariant.bodyLarge => BankingTypography.bodyLarge,
    AppTextVariant.bodyMedium => BankingTypography.bodyMedium,
    AppTextVariant.labelLarge => BankingTypography.labelLarge,
    AppTextVariant.labelSmall => BankingTypography.labelSmall,
  };

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _baseStyle.copyWith(color: color),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

// --- Previews ---

  @Preview(
    name: 'Typography System',
    group: 'AppText',
    wrapper: appPreviewWrapper,
  )
  static Widget typoPreview() => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText('Headline Large', variant: AppTextVariant.headlineLarge),
          AppText('Headline Medium', variant: AppTextVariant.headlineMedium),
          AppText('Title Large', variant: AppTextVariant.titleLarge),
          AppText('Title Medium', variant: AppTextVariant.titleMedium),
          AppText('Body Large', variant: AppTextVariant.bodyLarge),
          AppText('Body Medium'),
          AppText('Label Large', variant: AppTextVariant.labelLarge),
          AppText('Label Small', variant: AppTextVariant.labelSmall),
        ],
      );
}
