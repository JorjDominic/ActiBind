import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/devices/models/registered_device.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PcDeviceActivityPage extends StatelessWidget {
  const PcDeviceActivityPage({super.key, required this.device});

  final RegisteredDevice device;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(device.name)),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('PC Activity', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          '${device.platform} · ${device.connected ? 'Connected' : 'Offline'}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: _PcStat(
                value: '5h 08m',
                label: 'Active time',
                color: AppColors.indigo,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _PcStat(
                value: '3h 42m',
                label: 'Focused',
                color: AppColors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Desktop usage', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        const _PcApp(
          name: 'Chrome',
          duration: '2h 04m',
          icon: Icons.language_rounded,
        ),
        const _PcApp(
          name: 'Visual Studio Code',
          duration: '1h 38m',
          icon: Icons.code_rounded,
        ),
        const _PcApp(
          name: 'Documents',
          duration: '46m',
          icon: Icons.description_outlined,
        ),
        const SizedBox(height: 18),
        Text(
          'Monitoring status',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        shad.Card(
          child: const ListTile(
            leading: Icon(Icons.monitor_heart_rounded, color: AppColors.teal),
            title: Text('PC activity monitoring is active'),
            subtitle: Text(
              'Usage will be compared with your scheduled activities.',
            ),
          ),
        ),
      ],
    ),
  );
}

class _PcStat extends StatelessWidget {
  const _PcStat({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => shad.Card(
    filled: true,
    fillColor: color.withValues(alpha: .08),
    borderColor: color.withValues(alpha: .2),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

class _PcApp extends StatelessWidget {
  const _PcApp({
    required this.name,
    required this.duration,
    required this.icon,
  });
  final String name;
  final String duration;
  final IconData icon;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: CircleAvatar(child: Icon(icon, size: 19)),
    title: Text(name),
    trailing: Text(
      duration,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
