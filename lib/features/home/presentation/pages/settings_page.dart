import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/settings/family_mode_controller.dart';
import 'package:actibind/core/settings/developer_mode_controller.dart';
import 'package:actibind/core/settings/daily_summary_controller.dart';
import 'package:actibind/core/services/supabase_service.dart';
import 'package:actibind/features/auth/services/auth_service.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/core/theme/theme_controller.dart';
import 'package:actibind/features/developer/presentation/developer_diagnostics_page.dart';
import 'package:actibind/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onSignOut});

  final Future<void> Function()? onSignOut;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
              _SettingsSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AppearanceOption(
                              mode: ThemeMode.light,
                              label: 'Light',
                              icon: Icons.light_mode_rounded,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                    const SizedBox(height: 8),
                    Text(
                      'System follows your device appearance automatically.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: FamilyModeController.instance,
                builder: (context, _) => _SettingsSurface(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    value: FamilyModeController.instance.enabled,
                    onChanged: FamilyModeController.instance.setEnabled,
                    secondary: const _SettingIcon(
                      icon: Icons.family_restroom_rounded,
                      color: AppColors.indigo,
                    ),
                    title: const Text(
                      'Family mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Show family controls and restrictions in navigation',
                      style: TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: DailySummaryController.instance,
                builder: (context, _) => _SettingsSurface(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    value: DailySummaryController.instance.enabled,
                    onChanged: DailySummaryController.instance.setEnabled,
                    secondary: const _SettingIcon(
                      icon: Icons.notifications_active_outlined,
                      color: AppColors.teal,
                    ),
                    title: const Text(
                      'Daily summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Receive a daily overview of your focus and activity',
                      style: TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: DeveloperModeController.instance,
                builder: (context, _) => _SettingsSurface(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    value: DeveloperModeController.instance.enabled,
                    onChanged: DeveloperModeController.instance.setEnabled,
                    secondary: const _SettingIcon(
                      icon: Icons.developer_mode_rounded,
                      color: AppColors.amber,
                    ),
                    title: const Text(
                      'Developer mode',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Show diagnostics and service usage information',
                      style: TextStyle(fontSize: 12, height: 1.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Account',
            icon: Icons.person_rounded,
            color: AppColors.teal,
            children: [
              _SettingsTile(
                icon: Icons.account_circle_outlined,
                title: 'Profile',
                subtitle: 'Update your name, photo, and email',
                onTap: () => _editProfile(context),
              ),
              SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.security_rounded,
                title: 'Security',
                subtitle: 'Change password and app lock settings',
                onTap: () => _openSecurity(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Support',
            icon: Icons.support_agent_rounded,
            color: AppColors.amber,
            children: [
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help center',
                subtitle: 'Find guides and troubleshooting tips',
                onTap: () => _showHelp(context),
              ),
              SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About ActiBind',
                subtitle: 'Version, privacy policy, and legal details',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'ActiBind',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Privacy-first activity and family controls.',
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: DeveloperModeController.instance,
            builder: (context, _) {
              if (!DeveloperModeController.instance.enabled) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _SettingsSection(
                  title: 'Developer',
                  icon: Icons.code_rounded,
                  color: AppColors.indigo,
                  children: [
                    _SettingsTile(
                      icon: Icons.monitor_heart_outlined,
                      title: 'Diagnostics',
                      subtitle: 'AI tokens, service status, session, and build',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DeveloperDiagnosticsPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.onSignOut != null) ...[
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

    if (confirmed == true) await widget.onSignOut?.call();
  }

  Future<void> _editProfile(BuildContext context) async {
    final user = AuthService.currentUser;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditProfileDialog(
        initialName: user?.userMetadata?['full_name'] as String? ?? '',
      ),
    );
    if (name != null && name.isNotEmpty) {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(data: {'full_name': name}),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          this.context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      }
    }
  }

  Future<void> _openSecurity(BuildContext context) async {
    final email = AuthService.currentUser?.email;
    if (email == null) return;
    final send = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Security'),
        content: Text('Send a password reset link to $email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    if (send == true) {
      await AuthService.resetPassword(email: email);
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent.')),
        );
      }
    }
  }

  void _showHelp(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Help center'),
      content: const Text(
        'Use Family to create child profiles and start Child Mode. Use Activity to review schedules and device usage. For account access issues, use Security to request a password reset.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit profile'),
    content: TextField(
      controller: _name,
      autofocus: true,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _save(),
      decoration: const InputDecoration(labelText: 'Full name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );

  void _save() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
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
    return Column(
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: .35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _SettingIcon(icon: icon, color: colors.primary),
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
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSurface extends StatelessWidget {
  const _SettingsSurface({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: .3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .65)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: color),
  );
}
