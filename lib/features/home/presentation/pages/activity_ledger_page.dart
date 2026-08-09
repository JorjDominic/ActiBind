import 'package:actibind/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ActivityLedgerPage extends StatelessWidget {
  const ActivityLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shad.Card(
            filled: true,
            fillColor: isDark
                ? const Color(0xFF431E12)
                : const Color(0xFFFFF7ED),
            borderColor: isDark
                ? const Color(0xFF9A4B2E)
                : const Color(0xFFFED7AA),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFC2410C),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Focus conflict detected',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Instagram has been active for 12 minutes during your Work Deep-Dive block.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Total Focus',
            value: '4h 20m',
            subtitle: 'Blocks left • 3',
          ),
          const SizedBox(height: 16),
          const Text(
            'Today’s Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ScheduleTile(
            time: '07:00 AM - 08:30 AM',
            label: 'Exercise',
            description:
                'Morning high-intensity interval training at local park.',
            status: 'Done',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _ScheduleTile(
            time: '09:00 AM - 12:00 PM',
            label: 'Deep Work: Project Aurora',
            description:
                'Focused coding and documentation update. Slack and browser restricted.',
            status: 'Now',
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _ScheduleTile(
            time: '02:00 PM - 03:30 PM',
            label: 'Language Study',
            description: 'Spanish vocabulary and conversational practice.',
            status: 'Next Up',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.time,
    required this.label,
    required this.description,
    required this.status,
    required this.color,
  });

  final String time;
  final String label;
  final String description;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    time,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(description),
          ],
        ),
      ),
    );
  }
}
