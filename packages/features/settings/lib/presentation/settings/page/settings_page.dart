import 'dart:async';

import 'package:common/di/common_providers.dart';
import 'package:common/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui/tokens/colors.dart';
import '../bloc/settings_bloc.dart';

/// Page showing the app settings with toggle options.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.onAbout,
  });

  /// Callback when the "About" item is tapped.
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text(LocaleKeys.settings_title.tr()),
        backgroundColor: BankingColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Appearance section.
              _SectionHeader(title: LocaleKeys.settings_section_appearance.tr()),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: LocaleKeys.settings_dark_mode_title.tr(),
                subtitle: state.isDarkMode
                    ? LocaleKeys.settings_dark_mode_enabled.tr()
                    : LocaleKeys.settings_dark_mode_disabled.tr(),
                trailing: Switch.adaptive(
                  value: state.isDarkMode,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const ToggleTheme());
                  },
                  activeTrackColor: BankingColors.primary,
                ),
              ),
              const Divider(indent: 56, height: 1),
              // Security section.
              _SectionHeader(title: LocaleKeys.settings_section_security.tr()),
              _SettingsTile(
                icon: Icons.fingerprint,
                title: LocaleKeys.settings_biometrics_title.tr(),
                subtitle: state.isBiometricsEnabled
                    ? LocaleKeys.settings_biometrics_enabled.tr()
                    : LocaleKeys.settings_biometrics_disabled.tr(),
                trailing: Switch.adaptive(
                  value: state.isBiometricsEnabled,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(const ToggleBiometrics());
                  },
                  activeTrackColor: BankingColors.primary,
                ),
              ),
              const Divider(indent: 56, height: 1),
              // Notifications section.
              _SectionHeader(title: LocaleKeys.settings_section_notifications.tr()),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: LocaleKeys.settings_push_notifications_title.tr(),
                subtitle: state.areNotificationsEnabled
                    ? LocaleKeys.settings_push_notifications_enabled.tr()
                    : LocaleKeys.settings_push_notifications_disabled.tr(),
                trailing: Switch.adaptive(
                  value: state.areNotificationsEnabled,
                  onChanged: (_) {
                    context.read<SettingsBloc>().add(
                      const ToggleNotifications(),
                    );
                  },
                  activeTrackColor: BankingColors.primary,
                ),
              ),
              const Divider(indent: 56, height: 1),
              // General section.
              _SectionHeader(title: LocaleKeys.settings_section_general.tr()),
              _SettingsTile(
                icon: Icons.language,
                title: LocaleKeys.settings_language_title.tr(),
                subtitle: LocaleKeys.settings_language_value.tr(),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: BankingColors.onBackgroundLightSecondary,
                ),
                onTap: () => _showLanguagePicker(context),
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                icon: Icons.info_outline,
                title: LocaleKeys.settings_about_title.tr(),
                subtitle: LocaleKeys.settings_about_version.tr(),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: BankingColors.onBackgroundLightSecondary,
                ),
                onTap: onAbout,
              ),
              const Divider(indent: 56, height: 1),
              const SizedBox(height: 24),
              // Logout button.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: state.status.isLoggingOut
                        ? null
                        : () => context
                            .read<SettingsBloc>()
                            .add(const LogoutRequested()),
                    icon: state.status.isLoggingOut
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    label: Text(LocaleKeys.settings_logout.tr()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BankingColors.error,
                      side: const BorderSide(color: BankingColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final currentLocale = context.locale;

    Future<void> onLanguageSelected(Locale locale, BuildContext sheetContext) async {
      if (locale.languageCode == currentLocale.languageCode) {
        Navigator.of(sheetContext).pop();
        return;
      }
      Navigator.of(sheetContext).pop();
      await context.setLocale(locale);
      if (context.mounted) {
        ProviderScope.containerOf(context)
            .read(CommonProviders.localeChangeNotifier.notifier)
            .rebuild();
      }
    }

    unawaited(showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _LanguageOption(
                  flag: '🇪🇸',
                  label: 'Español',
                  locale: const Locale('es'),
                  isSelected: currentLocale.languageCode == 'es',
                  onTap: () => unawaited(
                    onLanguageSelected(const Locale('es'), sheetContext),
                  ),
                ),
                _LanguageOption(
                  flag: '🇬🇧',
                  label: 'English',
                  locale: const Locale('en'),
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () => unawaited(
                    onLanguageSelected(const Locale('en'), sheetContext),
                  ),
                ),
                _LanguageOption(
                  flag: '🇵🇹',
                  label: 'Português',
                  locale: const Locale('pt'),
                  isSelected: currentLocale.languageCode == 'pt',
                  onTap: () => unawaited(
                    onLanguageSelected(const Locale('pt'), sheetContext),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ));
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(flag, style: const TextStyle(fontSize: 28)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? BankingColors.primary
              : BankingColors.onBackgroundLight,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: BankingColors.primary)
          : null,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: BankingColors.onBackgroundLightSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: BankingColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: BankingColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: BankingColors.onBackgroundLight,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: BankingColors.onBackgroundLightSecondary,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
