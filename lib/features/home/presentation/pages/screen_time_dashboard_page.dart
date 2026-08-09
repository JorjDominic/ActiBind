import 'package:actibind/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ScreenTimeDashboardPage extends StatelessWidget {
  const ScreenTimeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shad.Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Daily Insight',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You’re 15% more focused than last Tuesday. Keep the momentum!',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const _MetricCard(
            label: 'Usage Today',
            value: '4h 12m',
            subtitle: 'of 6h',
            showCircle: true,
          ),
          const SizedBox(height: 16),
          const _MetricCard(
            label: 'Weekly Average',
            value: 'T: 4h',
            subtitle: 'Goal progress and trends',
            showBars: true,
          ),
          const SizedBox(height: 16),
          const _MetricCard(
            label: 'Goal Progress',
            value: '80%',
            subtitle: 'Screen Detox',
            showProgress: true,
          ),
          const SizedBox(height: 16),
          shad.Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productive peak hours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your strongest focus window is 9:00 AM–11:30 AM.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 112,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _DayBar(index: .45),
                        _DayBar(index: .7),
                        _DayBar(index: .9),
                        _DayBar(index: 1),
                        _DayBar(index: .75),
                        _DayBar(index: .5),
                        _DayBar(index: .4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.showCircle = false,
    this.showBars = false,
    this.showProgress = false,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool showCircle;
  final bool showBars;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            if (showCircle)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 12,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(subtitle),
                      ],
                    ),
                  ],
                ),
              )
            else if (showBars)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                      (index) => _DayBar(index: index == 3 ? 1.0 : 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(subtitle),
                ],
              )
            else if (showProgress)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.8),
                  const SizedBox(height: 8),
                  Text(subtitle),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.index});

  final double index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 100 * index,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
