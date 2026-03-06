import 'package:common/di/common_providers.dart';
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
    this.onLogout,
  });

  /// Callback when the "About" item is tapped.
  final VoidCallback? onAbout;

  /// Callback when the "Logout" item is tapped.
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BankingColors.backgroundLight,
      appBar: AppBar(
        title: Text('settings.title'.tr()),
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
              _SectionHeader(title: 'settings.section.appearance'.tr()),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'settings.dark_mode.title'.tr(),
                subtitle: state.isDarkMode
                    ? 'settings.dark_mode.enabled'.tr()
                    : 'settings.dark_mode.disabled'.tr(),
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
              _SectionHeader(title: 'settings.section.security'.tr()),
              _SettingsTile(
                icon: Icons.fingerprint,
                title: 'settings.biometrics.title'.tr(),
                subtitle: state.isBiometricsEnabled
                    ? 'settings.biometrics.enabled'.tr()
                    : 'settings.biometrics.disabled'.tr(),
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
              _SectionHeader(title: 'settings.section.notifications'.tr()),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'settings.push_notifications.title'.tr(),
                subtitle: state.areNotificationsEnabled
                    ? 'settings.push_notifications.enabled'.tr()
                    : 'settings.push_notifications.disabled'.tr(),
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
              _SectionHeader(title: 'settings.section.general'.tr()),
              _SettingsTile(
                icon: Icons.language,
                title: 'settings.language.title'.tr(),
                subtitle: 'settings.language.value'.tr(),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: BankingColors.onBackgroundLightSecondary,
                ),
                onTap: () => _showLanguagePicker(context),
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'settings.about.title'.tr(),
                subtitle: 'settings.about.version'.tr(),
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
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout),
                    label: Text('settings.logout'.tr()),
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

    showModalBottomSheet<void>(
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
                  onTap: () =>
                      onLanguageSelected(const Locale('es'), sheetContext),
                ),
                _LanguageOption(
                  flag: '🇬🇧',
                  label: 'English',
                  locale: const Locale('en'),
                  isSelected: currentLocale.languageCode == 'en',
                  onTap: () =>
                      onLanguageSelected(const Locale('en'), sheetContext),
                ),
                _LanguageOption(
                  flag: '🇵🇹',
                  label: 'Português',
                  locale: const Locale('pt'),
                  isSelected: currentLocale.languageCode == 'pt',
                  onTap: () =>
                      onLanguageSelected(const Locale('pt'), sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
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
