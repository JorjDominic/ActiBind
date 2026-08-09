import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/settings/family_mode_controller.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/core/theme/theme_controller.dart';
import 'package:actibind/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.onSignOut});

  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Settings',
            subtitle: 'Manage your account, alerts, and app behavior',
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            title: 'Preferences',
            icon: Icons.tune_rounded,
            color: AppColors.indigo,
            children: [
              const Text(
                'Appearance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: ThemeController.instance,
                builder: (context, _) => Row(
                  children: [
                    Expanded(
                      child: _AppearanceOption(
                        mode: ThemeMode.system,
                        label: 'System',
                        icon: Icons.brightness_auto_rounded,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _AppearanceOption(
                        mode: ThemeMode.light,
                        label: 'Light',
                        icon: Icons.light_mode_rounded,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _AppearanceOption(
                        mode: ThemeMode.dark,
                        label: 'Dark',
                        icon: Icons.dark_mode_rounded,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'System follows your device appearance automatically.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: FamilyModeController.instance,
                builder: (context, _) => Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: FamilyModeController.instance.enabled,
                    onChanged: FamilyModeController.instance.setEnabled,
                    secondary: const Icon(Icons.family_restroom_rounded),
                    title: const Text('Family mode'),
                    subtitle: const Text(
                      'Show family controls and restrictions in navigation',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Daily summary notifications'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Account',
            icon: Icons.person_rounded,
            color: AppColors.teal,
            children: const [
              _SettingsTile(
                icon: Icons.account_circle_outlined,
                title: 'Profile',
                subtitle: 'Update your name, photo, and email',
              ),
              SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.security_rounded,
                title: 'Security',
                subtitle: 'Change password and app lock settings',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Support',
            icon: Icons.support_agent_rounded,
            color: AppColors.amber,
            children: const [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help center',
                subtitle: 'Find guides and troubleshooting tips',
              ),
              SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About ActiBind',
                subtitle: 'Version, privacy policy, and legal details',
              ),
            ],
          ),
          if (onSignOut != null) ...[
            const SizedBox(height: 16),
            shad.Card(
              borderColor: AppColors.coral.withValues(alpha: .25),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 19,
                            color: AppColors.coral,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign out',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'End your current ActiBind session',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coral,
                        side: BorderSide(
                          color: AppColors.coral.withValues(alpha: .5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out of ActiBind?'),
        content: const Text(
          'You will need to enter your email and password to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign Out'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
          ),
        ],
      ),
    );

    if (confirmed == true) await onSignOut?.call();
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.mode,
    required this.label,
    required this.icon,
  });

  final ThemeMode mode;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final selected = ThemeController.instance.mode == mode;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ThemeController.instance.setMode(mode),
        child: SizedBox(
          height: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      borderColor: color.withValues(alpha: .2),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: color),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
