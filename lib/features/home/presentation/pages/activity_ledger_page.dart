import 'package:actibind/core/constants/app_constants.dart';
import 'package:forui/forui.dart';
import 'package:flutter/material.dart';

class ActivityLedgerPage extends StatelessWidget {
  const ActivityLedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            description: 'Morning high-intensity interval training at local park.',
            status: 'Done',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _ScheduleTile(
            time: '09:00 AM - 12:00 PM',
            label: 'Deep Work: Project Aurora',
            description: 'Focused coding and documentation update. Slack and browser restricted.',
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
  const _InfoCard({required this.title, required this.value, required this.subtitle});

  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
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
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(description),
          ],
        ),
      ),
    );
  }
}
