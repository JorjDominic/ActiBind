import 'package:actibind/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChildRestrictionPage extends StatelessWidget {
  const ChildRestrictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Keep your child’s study and play routines balanced with scheduled restrictions and safe access controls.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _RestrictionCard(
            title: 'Focus Lock',
            subtitle: 'Block distracting apps during school hours',
            icon: Icons.lock,
            progress: '3 of 5 apps restricted',
          ),
          const SizedBox(height: 12),
          _RestrictionCard(
            title: 'Bedtime Mode',
            subtitle: 'Limit screen time after 9:00 PM',
            icon: Icons.bedtime,
            progress: '8:00 PM - 9:30 PM',
          ),
          const SizedBox(height: 12),
          _RestrictionCard(
            title: 'Allowed Apps',
            subtitle: 'Only study and learning apps are available',
            icon: Icons.check_circle_outline,
            progress: '12 allowed',
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _ActivityTile(
            label: 'Instagram blocked',
            detail: '09:15 AM - During focus block',
          ),
          const SizedBox(height: 8),
          _ActivityTile(
            label: 'Homework timer started',
            detail: '08:30 AM - 9:15 AM',
          ),
          const SizedBox(height: 8),
          _ActivityTile(
            label: 'Relaxation access granted',
            detail: 'After bedtime window',
          ),
        ],
      ),
    );
  }
}

class _RestrictionCard extends StatelessWidget {
  const _RestrictionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String progress;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.label, required this.detail});

  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              detail,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
