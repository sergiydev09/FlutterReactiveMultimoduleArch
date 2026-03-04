import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: const Text('Ajustes'),
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
              const _SectionHeader(title: 'Apariencia'),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Modo oscuro',
                subtitle: state.isDarkMode ? 'Activado' : 'Desactivado',
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
              const _SectionHeader(title: 'Seguridad'),
              _SettingsTile(
                icon: Icons.fingerprint,
                title: 'Autenticación biométrica',
                subtitle: state.isBiometricsEnabled
                    ? 'Activada'
                    : 'Desactivada',
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
              const _SectionHeader(title: 'Notificaciones'),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notificaciones push',
                subtitle: state.areNotificationsEnabled
                    ? 'Activadas'
                    : 'Desactivadas',
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
              const _SectionHeader(title: 'General'),
              _SettingsTile(
                icon: Icons.language,
                title: 'Idioma',
                subtitle: 'Español',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: BankingColors.onBackgroundLightSecondary,
                ),
                onTap: () {
                  // Language selection.
                },
              ),
              const Divider(indent: 56, height: 1),
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Acerca de',
                subtitle: 'Versión 1.0.0',
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
                    label: const Text('Cerrar sesión'),
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
