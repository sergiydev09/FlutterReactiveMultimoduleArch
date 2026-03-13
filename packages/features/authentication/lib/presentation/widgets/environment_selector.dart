import 'package:common/config/environment.dart';
import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:ui/tokens/colors.dart';
import 'package:ui/utils/preview_wrapper.dart';

/// A widget that allows developers to switch between environments.
///
/// Should only be visible in non-production builds.
class EnvironmentSelector extends StatefulWidget {
  const EnvironmentSelector({
    super.key,
    this.initialEnvironment = Environment.mock,
    this.onChanged,
  });

  /// The initially selected environment.
  final Environment initialEnvironment;

  /// Callback when the environment is changed.
  final void Function(Environment environment)? onChanged;

  @override
  State<EnvironmentSelector> createState() => _EnvironmentSelectorState();
}

class _EnvironmentSelectorState extends State<EnvironmentSelector> {
  late Environment _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialEnvironment;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BankingColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BankingColors.dividerLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.environment_selector_label.tr(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: BankingColors.onBackgroundLightSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: Environment.values.map((env) {
              final isSelected = env == _selected;
              final label = switch (env) {
                Environment.mock => 'MOCK',
                Environment.pre => 'PRE',
                Environment.pro => 'PRO',
              };
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selected = env;
                      });
                      widget.onChanged?.call(env);
                    },
                    selectedColor: BankingColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : BankingColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Previews ---

@Preview(
  name: 'Environment Selector',
  group: 'Authentication',
  wrapper: appPreviewWrapper,
)
Widget environmentSelectorPreview() => EnvironmentSelector(
      onChanged: (env) => debugPrint('Environment changed to: $env'),
    );
