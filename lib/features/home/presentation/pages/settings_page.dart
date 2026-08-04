import 'package:actibind/core/constants/app_constants.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your account, alerts, and app behavior from one place.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Preferences',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: true,
                onChanged: (_) {},
                title: const Text('Daily summary notifications'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: false,
                onChanged: (_) {},
                title: const Text('Dark mode follow system'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Account',
            children: const [
              _SettingsTile(
                title: 'Profile',
                subtitle: 'Update your name, photo, and email',
              ),
              SizedBox(height: 12),
              _SettingsTile(
                title: 'Security',
                subtitle: 'Change password and app lock settings',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Support',
            children: const [
              _SettingsTile(
                title: 'Help center',
                subtitle: 'Find guides and troubleshooting tips',
              ),
              SizedBox(height: 12),
              _SettingsTile(
                title: 'About Actibind',
                subtitle: 'Version, privacy policy, and legal details',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}