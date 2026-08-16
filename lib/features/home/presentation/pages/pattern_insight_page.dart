import 'package:actibind/features/home/presentation/pages/screen_time_dashboard_page.dart';
import 'package:flutter/material.dart';

/// Backward-compatible entry point for the former static pattern screen.
/// All insight routes now render the synchronized dashboard.
class PatternInsightPage extends StatelessWidget {
  const PatternInsightPage({super.key});

  @override
  Widget build(BuildContext context) => const ScreenTimeDashboardPage();
}
