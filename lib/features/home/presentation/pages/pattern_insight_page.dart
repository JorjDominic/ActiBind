import 'package:actibind/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class PatternInsightPage extends StatelessWidget {
  const PatternInsightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Productive Peak Hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _BarChart(),
                SizedBox(height: 16),
                Text('You are most effective between 09:00 AM and 11:30 AM.', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Sleep Hygiene Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Late Night Scroll Alert', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Screen usage spiked 40% after midnight yesterday. Your restorative sleep was reduced by 1.5 hours.'),
                SizedBox(height: 12),
                Text('Set Wind-down', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart();

  @override
  Widget build(BuildContext context) {
    final bars = [0.5, 0.8, 0.6, 1.0, 0.7, 0.4, 0.45];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: bars
          .map(
            (height) => Container(
              width: 18,
              height: 120 * height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
          .toList(),
    );
  }
}
